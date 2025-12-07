// booking-page12_v09.js

/* =============================================================================================================
  Author       : Tim O’Leary
  Student ID   : 23287021
  Version      : 1.0
  Program      : Higher Diploma in Science in Computing
  Module       : Project (HDSDEV_JAN25)
  Lecturer     : Lisa Murphy

  Description  : Client-side script for Booking page (booking-page12.js).
                 - Renders resource detail panel and wires UI actions without inline onclick attributes.
                 - Uses apex.server.process("AJAXCB_GOTO_MODAL") AJAX action on the server to obtain a safe modal URL.
                 
============================================================================================================= */

(function () {
  'use strict';

  // ---- small helper: wait until APEX client is reachable ----
  // Keep the wait short but tolerant; fail fast with a clear error if APEX never appears.
  function whenApexReady(callback, timeoutMs) {
    timeoutMs = timeoutMs || 5000;
    var start = Date.now();
    (function check() {
      if (window.apex && apex.server && typeof apex.server.process === 'function') {
        console.info('booking-page: APEX client ready');
        return callback();
      }
      if (Date.now() - start > timeoutMs) {
        console.error('booking-page: APEX client did not appear within', timeoutMs, 'ms - aborting init');
        return;
      }
      setTimeout(check, 50);
    }());
  }

  // ---- entry point ----
  whenApexReady(function initBooking() {
    console.info('booking-page: bootstrap start');

    // UI element references (panel where details are rendered)
    window.panelTitle = document.getElementById('panelTitle');
    window.panelMeta = document.getElementById('panelMeta');
    window.panelContent = document.getElementById('panelContent');

    // ---- utilities ----

    // Escape text for safe HTML insertion
    function escapeHtml(s) {
      return String(s == null ? '' : s)
        .replace(/&/g, '&amp;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        .replace(/"/g, '&quot;')
        .replace(/'/g, '&#039;');
    }

    // Escape for CSS selector usage (best-effort)
    function escCss(s) {
      if (!s) return s;
      if (window.CSS && CSS.escape) return CSS.escape(s);
      return String(s).replace(/([ #;,.+*~:'"!^$[\]()=>|\/@\\])/g, '\\$1');
    }



    // ---- fetch resources and wire UI ----
    apex.server.process('GET_RESOURCES', {}, {
      success: function (data) {
        var items = data && data.items;
        if (!items || typeof items !== 'object') {
          console.error('booking-page: GET_RESOURCES returned unexpected items', items);
          return;
        }

        // keep a copy on window for debugging and for other code paths
        window.__bookingItems = items;
        console.debug('booking-page: loaded', Object.keys(items).length, 'items');

        // Attach click/keyboard behaviour to the resource elements in the DOM
        Object.keys(items).forEach(function (id) {
          // try multiple selectors for resilience
          var el = document.getElementById(id)
                || document.querySelector('[data-code="' + escCss(id) + '"]')
                || document.querySelector('#' + escCss(id));
          if (!el) {
            // It's fine if some items aren't in the DOM; log for traceability
            console.debug('booking-page: DOM element not found for resource id', id);
            return;
          }

          // Normal click selects the item
          el.addEventListener('click', function () {
            if (typeof window.selectItem === 'function') window.selectItem(id);
          });

          // Make keyboard-accessible
          el.setAttribute('tabindex', '0');
          el.setAttribute('role', 'button');
          try { el.setAttribute('aria-label', (items[id].name || '') + ', ' + (items[id].type || '')); } catch (e) {}

          el.addEventListener('keydown', function (e) {
            if (e.key === 'Enter' || e.key === ' ') {
              e.preventDefault();
              if (typeof window.selectItem === 'function') window.selectItem(id);
            }
          });

          // visual state for occupied items
          if (items[id].status === 'Occupied') el.classList.add('occupied');
        });

        // ---- selectItem: show details in the right-hand panel ----
        window.selectItem = function (id) {
          var it = items[id];
          if (!it) {
            console.warn('booking-page: selectItem called with unknown id', id);
            return;
          }

          var sType = (it.type === 'Equipment') ? ' \u2022 Available ' : ' \u2022 Capacity ';
          if (window.panelTitle) window.panelTitle.textContent = it.name || '';
          if (window.panelMeta) window.panelMeta.textContent = (it.type || '') + sType + (it.capacity || '');
          if (window.panelContent) {
            window.panelContent.innerHTML = (typeof renderDetails === 'function') ? renderDetails(it) : '<div>' + escapeHtml(it.name) + '</div>';
          }

          // reset scroll top for the info panel if it exists
          try { var info = document.getElementById('infoPanel'); if (info) info.scrollTop = 0; } catch (e) {}

          // Wire any Schedule buttons rendered inside the details HTML
          try {
            var scheduleButtons = window.panelContent.querySelectorAll('.btn-schedule');
            scheduleButtons.forEach(function (btn) {
              // Defensive: ensure the button will not submit a form
              if (!btn.getAttribute('type')) btn.setAttribute('type', 'button');

              // Remove previously attached handlers by replacing the node
              var fresh = btn.cloneNode(true);
              btn.parentNode.replaceChild(fresh, btn);

              fresh.addEventListener('click', function (ev) {
                if (ev && ev.preventDefault) ev.preventDefault();
                // prefer the explicit data-id, fallback to the id in this selectItem call
                var targetId = fresh.getAttribute('data-id') || id;
                console.info('booking-page: Schedule clicked for', targetId);
                if (typeof window.schedule === 'function') window.schedule(targetId);
              });
            });
          } catch (e) {
            console.warn('booking-page: error wiring schedule buttons', e);
          }
        };

        // ---- schedule: show the create/back controls and launch modal when requested ----
        // Use a single, consistent schedule implementation that reads from `items`
        window.schedule = function (id) {
          var it = items && items[id] ? items[id] : null;
          if (!it || !window.panelContent) {
            console.warn('booking-page: schedule called with missing item or panelContent for id', id);
            return;
          }
          console.info('booking-page: opening schedule view for', id, 'resource_id=', it.resource_id);

          // Build the small schedule view (keep the HTML minimal and predictable)
          var html = [];
          html.push('<div style="font-weight:700">Schedule ' + escapeHtml(it.name) + '</div>');
          html.push('<div style="margin-top:8px;color:var(--muted)">Click Create Booking to reserve this spot.</div>');
          html.push('<div style="margin-top:12px" class="actions">');
          html.push('<button type="button" class="btn t-Button--icon t-Button--iconLeft t-Button--hoverIconPush" id="createBookingBtn"><span class="t-Icon t-Icon--left fa fa-calendar-plus-o"> </span>Create Booking</button>&nbsp;');
          html.push('<button type="button" class="btn secondary" id="backFromScheduleBtn">Back</button>');
          html.push('</div>');
          window.panelContent.innerHTML = html.join('');

          // Wire the Create Booking button
          var createBtn = document.getElementById('createBookingBtn');
          if (createBtn) {
            // replace to clear any stray handlers, then re-query for the new node reference
            createBtn.replaceWith(createBtn.cloneNode(true));
            createBtn = document.getElementById('createBookingBtn');

            createBtn.addEventListener('click', function (ev) {
              if (ev && ev.preventDefault) ev.preventDefault();
              console.info('booking-page: Create Booking clicked for', id);

              // payload: two values (resource_id,id) and the two target page item names
              var ajaxData = {
                x01: String((it.resource_id == null ? '' : it.resource_id)) + ',' + String((it.id == null ? '' : it.id)),
                x02: String(5), // modal page number - change this if your modal page is different
                x03: 'P5_RESOURCE_ID,P5_RESOURCE_BUTID'
              };

              try {
                apex.server.process('AJAXCB_GOTO_MODAL', ajaxData, {
                  success: function (resp) {
                    var url = resp && resp.url
                      ? resp.url
                      : // fallback build f?p url (values order must match item names)
                        'f?p=&APP_ID.:CREATE-BOOKING:&APP_SESSION.::::P5_RESOURCE_ID,P5_RESOURCE_BUTID:' +
                          encodeURIComponent(String(it.resource_id || '')) + ',' + encodeURIComponent(String(it.id || ''));

                    // Prefer dialog if available; otherwise redirect
                    if (resp && resp.url && window.apex && apex.navigation && typeof apex.navigation.dialog === 'function') {
                      try {
                        apex.navigation.dialog(null, url, { title: 'Booking' }, 't-Dialog-page--standard', function (closeAction) {
                          console.info('booking-page: booking dialog closed with action', closeAction);
                          if (closeAction === 'ok') {
                            try { apex.region('infoPanel').refresh(); } catch (e) { console.warn('booking-page: infoPanel refresh failed', e); }
                          }
                        });
                        return;
                      } catch (e) {
                        console.warn('booking-page: dialog launch failed, falling back to redirect', e);
                      }
                    }

                    // fallback behaviour: redirect using apex.navigation.redirect or window.location
                    if (window.apex && apex.navigation && typeof apex.navigation.redirect === 'function') {
                      apex.navigation.redirect(url);
                    } else {
                      window.location.href = url;
                    }
                  },
                  error: function () {
                    console.error('booking-page: AJAXCB_GOTO_MODAL failed - falling back to f?p redirect');
                    var fallback = 'f?p=&APP_ID.:CREATE-BOOKING:&APP_SESSION.::::P5_RESOURCE_ID,P5_RESOURCE_BUTID:' +
                      encodeURIComponent(String(it.resource_id || '')) + ',' + encodeURIComponent(String(it.id || ''));
                    if (window.apex && apex.navigation && typeof apex.navigation.redirect === 'function') apex.navigation.redirect(fallback);
                    else window.location.href = fallback;
                  }
                });
              } catch (e) {
                console.error('booking-page: unexpected error while launching modal, redirecting', e);
                var fallback2 = 'f?p=&APP_ID.:CREATE-BOOKING:&APP_SESSION.::::P5_RESOURCE_ID,P5_RESOURCE_BUTID:' +
                  encodeURIComponent(String(it.resource_id || '')) + ',' + encodeURIComponent(String(it.id || ''));
                if (window.apex && apex.navigation && typeof apex.navigation.redirect === 'function') apex.navigation.redirect(fallback2);
                else window.location.href = fallback2;
              }
            }, { once: true });
          } else {
            console.warn('booking-page: createBookingBtn not found after rendering schedule view for', id);
          }

          // Wire the Back button to restore the details view
          var backBtn = document.getElementById('backFromScheduleBtn');
          if (backBtn) {
            backBtn.replaceWith(backBtn.cloneNode(true));
            backBtn = document.getElementById('backFromScheduleBtn');
            backBtn.addEventListener('click', function (ev) {
              if (ev && ev.preventDefault) ev.preventDefault();
              console.info('booking-page: Back clicked - restoring details for', id);
              if (typeof window.selectItem === 'function') window.selectItem(id);
            }, { once: true });
          } else {
            console.warn('booking-page: backFromScheduleBtn not found for', id);
          }
        };

        // ---- confirmBooking: mark item as occupied and show simple confirmation ----
        window.confirmBooking = function (id) {
          if (!items[id]) {
            console.warn('booking-page: confirmBooking called for unknown id', id);
            return;
          }
          items[id].status = 'Occupied';
          var el = document.getElementById(id);
          if (el) el.classList.add('occupied');

          if (window.panelContent) {
            window.panelContent.innerHTML = '<div style="font-weight:700">Booked</div>'
              + '<div style="margin-top:8px;color:var(--muted)">A booking was recorded for <strong>' + escapeHtml(items[id].name) + '</strong>.</div>';
          }
          console.info('booking-page: item marked as Occupied', id);
        };

        // ---- if the page provided an initial resource id via item P12_RESOURCE_BUTID, emulate a click ----
        var requested = (apex.item && apex.item('P12_RESOURCE_BUTID')) ? apex.item('P12_RESOURCE_BUTID').getValue() : null;
        if (requested) {
          var rid = String(requested).trim();
          if (rid) {
            var el = document.getElementById(rid)
                 || document.querySelector('[data-code="' + escCss(rid) + '"]')
                 || document.querySelector('#' + escCss(rid));
            if (el) {
              try { el.focus(); } catch (e) {}
              // Try keyboard event first then click as a fallback
              var handled = false;
              try {
                var kd = new KeyboardEvent('keydown', { key: 'Enter', code: 'Enter', keyCode: 13, which: 13, bubbles: true, cancelable: true });
                handled = el.dispatchEvent(kd);
                var ku = new KeyboardEvent('keyup', { key: 'Enter', code: 'Enter', keyCode: 13, which: 13, bubbles: true, cancelable: true });
                el.dispatchEvent(ku);
              } catch (e) {
                handled = false;
              }
              if (!handled) {
                try { el.click(); } catch (e) { console.error('booking-page: requested element click failed', e); }
              }
            } else {
              console.warn('booking-page: requested resource id not found in DOM after GET_RESOURCES:', rid);
            }
          }
        }

      }, // end success
      error: function (req, status, err) {
        console.error('booking-page: GET_RESOURCES AJAX error', status, err, req && req.responseText);
      }
    }); // end apex.server.process(GET_RESOURCES)

    console.info('booking-page: bootstrap end');
  }, 5000); // end whenApexReady

})(); // end IIFE

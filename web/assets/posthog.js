//  browserify node_modules/posthog-js/dist/module.no-external.js --standalone posthog -p esmify  -o posthog.js


(function(f){if(typeof exports==="object"&&typeof module!=="undefined"){module.exports=f()}else if(typeof define==="function"&&define.amd){define([],f)}else{var g;if(typeof window!=="undefined"){g=window}else if(typeof global!=="undefined"){g=global}else if(typeof self!=="undefined"){g=self}else{g=this}g.posthog = f()}})(function(){var define,module,exports;return (function(){function r(e,n,t){function o(i,f){if(!n[i]){if(!e[i]){var c="function"==typeof require&&require;if(!f&&c)return c(i,!0);if(u)return u(i,!0);var a=new Error("Cannot find module '"+i+"'");throw a.code="MODULE_NOT_FOUND",a}var p=n[i]={exports:{}};e[i][0].call(p.exports,function(r){var n=e[i][1][r];return o(n||r)},p,p.exports,r,e,n,t)}return n[i].exports}for(var u="function"==typeof require&&require,i=0;i<t.length;i++)o(t[i]);return o}return r})()({1:[function(require,module,exports){
"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});
exports.severityLevels = exports.posthog = exports.knownUnsafeEditableEvent = exports.default = exports.SurveyType = exports.SurveyQuestionType = exports.SurveyQuestionBranchingType = exports.PostHog = exports.Compression = exports.COPY_AUTOCAPTURE_EVENT = void 0;
function e(e, t) {
  var i = Object.keys(e);
  if (Object.getOwnPropertySymbols) {
    var n = Object.getOwnPropertySymbols(e);
    t && (n = n.filter(function (t) {
      return Object.getOwnPropertyDescriptor(e, t).enumerable;
    })), i.push.apply(i, n);
  }
  return i;
}
function t(t) {
  for (var n = 1; n < arguments.length; n++) {
    var s = null != arguments[n] ? arguments[n] : {};
    n % 2 ? e(Object(s), !0).forEach(function (e) {
      i(t, e, s[e]);
    }) : Object.getOwnPropertyDescriptors ? Object.defineProperties(t, Object.getOwnPropertyDescriptors(s)) : e(Object(s)).forEach(function (e) {
      Object.defineProperty(t, e, Object.getOwnPropertyDescriptor(s, e));
    });
  }
  return t;
}
function i(e, t, i) {
  return t in e ? Object.defineProperty(e, t, {
    value: i,
    enumerable: !0,
    configurable: !0,
    writable: !0
  }) : e[t] = i, e;
}
function n(e, t) {
  if (null == e) return {};
  var i,
    n,
    s = function (e, t) {
      if (null == e) return {};
      var i,
        n,
        s = {},
        r = Object.keys(e);
      for (n = 0; n < r.length; n++) i = r[n], t.indexOf(i) >= 0 || (s[i] = e[i]);
      return s;
    }(e, t);
  if (Object.getOwnPropertySymbols) {
    var r = Object.getOwnPropertySymbols(e);
    for (n = 0; n < r.length; n++) i = r[n], t.indexOf(i) >= 0 || Object.prototype.propertyIsEnumerable.call(e, i) && (s[i] = e[i]);
  }
  return s;
}
var s,
  r = {
    DEBUG: !1,
    LIB_VERSION: "1.194.4"
  },
  o = "undefined" != typeof window ? window : void 0,
  a = "undefined" != typeof globalThis ? globalThis : o,
  l = Array.prototype,
  u = l.forEach,
  c = l.indexOf,
  d = null == a ? void 0 : a.navigator,
  h = null == a ? void 0 : a.document,
  _ = null == a ? void 0 : a.location,
  p = null == a ? void 0 : a.fetch,
  v = null != a && a.XMLHttpRequest && "withCredentials" in new a.XMLHttpRequest() ? a.XMLHttpRequest : void 0,
  g = null == a ? void 0 : a.AbortController,
  f = null == d ? void 0 : d.userAgent,
  m = null != o ? o : {},
  b = exports.COPY_AUTOCAPTURE_EVENT = "$copy_autocapture",
  y = exports.knownUnsafeEditableEvent = ["$snapshot", "$pageview", "$pageleave", "$set", "survey dismissed", "survey sent", "survey shown", "$identify", "$groupidentify", "$create_alias", "$$client_ingestion_warning", "$web_experiment_applied", "$feature_enrollment_update", "$feature_flag_called"];
!function (e) {
  e.GZipJS = "gzip-js", e.Base64 = "base64";
}(s || (exports.Compression = s = {}));
var w = exports.severityLevels = ["fatal", "error", "warning", "log", "info", "debug"],
  S = Array.isArray,
  E = Object.prototype,
  k = E.hasOwnProperty,
  x = E.toString,
  I = S || function (e) {
    return "[object Array]" === x.call(e);
  },
  C = e => "function" == typeof e,
  P = e => e === Object(e) && !I(e),
  R = e => {
    if (P(e)) {
      for (var t in e) if (k.call(e, t)) return !1;
      return !0;
    }
    return !1;
  },
  F = e => void 0 === e,
  T = e => "[object String]" == x.call(e),
  $ = e => T(e) && 0 === e.trim().length,
  O = e => null === e,
  M = e => F(e) || O(e),
  A = e => "[object Number]" == x.call(e),
  L = e => "[object Boolean]" === x.call(e),
  D = e => e instanceof FormData,
  N = e => G(y, e),
  q = "[PostHog.js]",
  B = {
    _log: function (e) {
      if (o && (r.DEBUG || m.POSTHOG_DEBUG) && !F(o.console) && o.console) {
        for (var t = ("__rrweb_original__" in o.console[e]) ? o.console[e].__rrweb_original__ : o.console[e], i = arguments.length, n = new Array(i > 1 ? i - 1 : 0), s = 1; s < i; s++) n[s - 1] = arguments[s];
        t(q, ...n);
      }
    },
    info: function () {
      for (var e = arguments.length, t = new Array(e), i = 0; i < e; i++) t[i] = arguments[i];
      B._log("log", ...t);
    },
    warn: function () {
      for (var e = arguments.length, t = new Array(e), i = 0; i < e; i++) t[i] = arguments[i];
      B._log("warn", ...t);
    },
    error: function () {
      for (var e = arguments.length, t = new Array(e), i = 0; i < e; i++) t[i] = arguments[i];
      B._log("error", ...t);
    },
    critical: function () {
      for (var e = arguments.length, t = new Array(e), i = 0; i < e; i++) t[i] = arguments[i];
      console.error(q, ...t);
    },
    uninitializedWarning: e => {
      B.error("You must initialize PostHog before calling ".concat(e));
    }
  },
  H = {},
  U = function (e) {
    return e.replace(/^[\s\uFEFF\xA0]+|[\s\uFEFF\xA0]+$/g, "");
  };
function z(e, t, i) {
  if (I(e)) if (u && e.forEach === u) e.forEach(t, i);else if ("length" in e && e.length === +e.length) for (var n = 0, s = e.length; n < s; n++) if (n in e && t.call(i, e[n], n) === H) return;
}
function W(e, t, i) {
  if (!M(e)) {
    if (I(e)) return z(e, t, i);
    if (D(e)) {
      for (var n of e.entries()) if (t.call(i, n[1], n[0]) === H) return;
    } else for (var s in e) if (k.call(e, s) && t.call(i, e[s], s) === H) return;
  }
}
var j = function (e) {
  for (var t = arguments.length, i = new Array(t > 1 ? t - 1 : 0), n = 1; n < t; n++) i[n - 1] = arguments[n];
  return z(i, function (t) {
    for (var i in t) void 0 !== t[i] && (e[i] = t[i]);
  }), e;
};
function G(e, t) {
  return -1 !== e.indexOf(t);
}
function V(e) {
  for (var t = Object.keys(e), i = t.length, n = new Array(i); i--;) n[i] = [t[i], e[t[i]]];
  return n;
}
var J = function (e) {
    try {
      return e();
    } catch (e) {
      return;
    }
  },
  Q = function (e) {
    return function () {
      try {
        for (var t = arguments.length, i = new Array(t), n = 0; n < t; n++) i[n] = arguments[n];
        return e.apply(this, i);
      } catch (e) {
        B.critical("Implementation error. Please turn on debug mode and open a ticket on https://app.posthog.com/home#panel=support%3Asupport%3A."), B.critical(e);
      }
    };
  },
  Y = function (e) {
    var t = {};
    return W(e, function (e, i) {
      T(e) && e.length > 0 && (t[i] = e);
    }), t;
  },
  X = function (e) {
    return e.replace(/^\$/, "");
  };
function K(e, t) {
  return i = e, n = e => T(e) && !O(t) ? e.slice(0, t) : e, s = new Set(), function e(t, i) {
    return t !== Object(t) ? n ? n(t, i) : t : s.has(t) ? void 0 : (s.add(t), I(t) ? (r = [], z(t, t => {
      r.push(e(t));
    })) : (r = {}, W(t, (t, i) => {
      s.has(t) || (r[i] = e(t, i));
    })), r);
    var r;
  }(i);
  var i, n, s;
}
var Z = function (e) {
    var t,
      i,
      n,
      s,
      r = "";
    for (t = i = 0, n = (e = (e + "").replace(/\r\n/g, "\n").replace(/\r/g, "\n")).length, s = 0; s < n; s++) {
      var o = e.charCodeAt(s),
        a = null;
      o < 128 ? i++ : a = o > 127 && o < 2048 ? String.fromCharCode(o >> 6 | 192, 63 & o | 128) : String.fromCharCode(o >> 12 | 224, o >> 6 & 63 | 128, 63 & o | 128), O(a) || (i > t && (r += e.substring(t, i)), r += a, t = i = s + 1);
    }
    return i > t && (r += e.substring(t, e.length)), r;
  },
  ee = function () {
    function e(t) {
      return t && (t.preventDefault = e.preventDefault, t.stopPropagation = e.stopPropagation), t;
    }
    return e.preventDefault = function () {
      this.returnValue = !1;
    }, e.stopPropagation = function () {
      this.cancelBubble = !0;
    }, function (t, i, n, s, r) {
      if (t) {
        if (t.addEventListener && !s) t.addEventListener(i, n, !!r);else {
          var a = "on" + i,
            l = t[a];
          t[a] = function (t, i, n) {
            return function (s) {
              if (s = s || e(null == o ? void 0 : o.event)) {
                var r,
                  a = !0;
                C(n) && (r = n(s));
                var l = i.call(t, s);
                return !1 !== r && !1 !== l || (a = !1), a;
              }
            };
          }(t, n, l);
        }
      } else B.error("No valid element provided to register_event");
    };
  }();
function te(e, t) {
  for (var i = 0; i < e.length; i++) if (t(e[i])) return e[i];
}
var ie = "$people_distinct_id",
  ne = "__alias",
  se = "__timers",
  re = "$autocapture_disabled_server_side",
  oe = "$heatmaps_enabled_server_side",
  ae = "$exception_capture_enabled_server_side",
  le = "$web_vitals_enabled_server_side",
  ue = "$dead_clicks_enabled_server_side",
  ce = "$web_vitals_allowed_metrics",
  de = "$session_recording_enabled_server_side",
  he = "$console_log_recording_enabled_server_side",
  _e = "$session_recording_network_payload_capture",
  pe = "$session_recording_canvas_recording",
  ve = "$replay_sample_rate",
  ge = "$replay_minimum_duration",
  fe = "$replay_script_config",
  me = "$sesid",
  be = "$session_is_sampled",
  ye = "$session_recording_url_trigger_activated_session",
  we = "$session_recording_event_trigger_activated_session",
  Se = "$enabled_feature_flags",
  Ee = "$early_access_features",
  ke = "$stored_person_properties",
  xe = "$stored_group_properties",
  Ie = "$surveys",
  Ce = "$surveys_activated",
  Pe = "$flag_call_reported",
  Re = "$user_state",
  Fe = "$client_session_props",
  Te = "$capture_rate_limit",
  $e = "$initial_campaign_params",
  Oe = "$initial_referrer_info",
  Me = "$initial_person_info",
  Ae = "$epp",
  Le = "__POSTHOG_TOOLBAR__",
  De = [ie, ne, "__cmpns", se, de, oe, me, Se, Re, Ee, xe, ke, Ie, Pe, Fe, Te, $e, Oe, Ae],
  Ne = "$active_feature_flags",
  qe = "$override_feature_flags",
  Be = "$feature_flag_payloads",
  He = e => {
    var t = {};
    for (var [i, n] of V(e || {})) n && (t[i] = n);
    return t;
  };
class Ue {
  constructor(e) {
    this.instance = e, this._override_warning = !1, this.featureFlagEventHandlers = [], this.reloadFeatureFlagsQueued = !1, this.reloadFeatureFlagsInAction = !1;
  }
  getFlags() {
    return Object.keys(this.getFlagVariants());
  }
  getFlagVariants() {
    var e = this.instance.get_property(Se),
      t = this.instance.get_property(qe);
    if (!t) return e || {};
    for (var i = j({}, e), n = Object.keys(t), s = 0; s < n.length; s++) i[n[s]] = t[n[s]];
    return this._override_warning || (B.warn(" Overriding feature flags!", {
      enabledFlags: e,
      overriddenFlags: t,
      finalFlags: i
    }), this._override_warning = !0), i;
  }
  getFlagPayloads() {
    return this.instance.get_property(Be) || {};
  }
  reloadFeatureFlags() {
    this.reloadFeatureFlagsQueued || (this.reloadFeatureFlagsQueued = !0, this._startReloadTimer());
  }
  setAnonymousDistinctId(e) {
    this.$anon_distinct_id = e;
  }
  setReloadingPaused(e) {
    this.reloadFeatureFlagsInAction = e;
  }
  resetRequestQueue() {
    this.reloadFeatureFlagsQueued = !1;
  }
  _startReloadTimer() {
    this.reloadFeatureFlagsQueued && !this.reloadFeatureFlagsInAction && setTimeout(() => {
      !this.reloadFeatureFlagsInAction && this.reloadFeatureFlagsQueued && (this.reloadFeatureFlagsQueued = !1, this._reloadFeatureFlagsRequest());
    }, 5);
  }
  _reloadFeatureFlagsRequest() {
    if (!this.instance.config.advanced_disable_feature_flags) {
      this.setReloadingPaused(!0);
      var e = this.instance.config.token,
        t = this.instance.get_property(ke),
        i = this.instance.get_property(xe),
        n = {
          token: e,
          distinct_id: this.instance.get_distinct_id(),
          groups: this.instance.getGroups(),
          $anon_distinct_id: this.$anon_distinct_id,
          person_properties: t,
          group_properties: i,
          disable_flags: this.instance.config.advanced_disable_feature_flags || void 0
        };
      this.instance._send_request({
        method: "POST",
        url: this.instance.requestRouter.endpointFor("api", "/decide/?v=3"),
        data: n,
        compression: this.instance.config.disable_compression ? void 0 : s.Base64,
        timeout: this.instance.config.feature_flag_request_timeout_ms,
        callback: e => {
          var t;
          this.setReloadingPaused(!1);
          var i = !0;
          200 === e.statusCode && (this.$anon_distinct_id = void 0, i = !1), this.receivedFeatureFlags(null !== (t = e.json) && void 0 !== t ? t : {}, i), this._startReloadTimer();
        }
      });
    }
  }
  getFeatureFlag(e) {
    var t = arguments.length > 1 && void 0 !== arguments[1] ? arguments[1] : {};
    if (this.instance.decideEndpointWasHit || this.getFlags() && this.getFlags().length > 0) {
      var i,
        n = this.getFlagVariants()[e],
        s = "".concat(n),
        r = this.instance.get_property(Pe) || {};
      if (t.send_event || !("send_event" in t)) if (!(e in r) || !r[e].includes(s)) I(r[e]) ? r[e].push(s) : r[e] = [s], null === (i = this.instance.persistence) || void 0 === i || i.register({
        [Pe]: r
      }), this.instance.capture("$feature_flag_called", {
        $feature_flag: e,
        $feature_flag_response: n
      });
      return n;
    }
    B.warn('getFeatureFlag for key "' + e + "\" failed. Feature flags didn't load in time.");
  }
  getFeatureFlagPayload(e) {
    return this.getFlagPayloads()[e];
  }
  isFeatureEnabled(e) {
    var t = arguments.length > 1 && void 0 !== arguments[1] ? arguments[1] : {};
    if (this.instance.decideEndpointWasHit || this.getFlags() && this.getFlags().length > 0) return !!this.getFeatureFlag(e, t);
    B.warn('isFeatureEnabled for key "' + e + "\" failed. Feature flags didn't load in time.");
  }
  addFeatureFlagsHandler(e) {
    this.featureFlagEventHandlers.push(e);
  }
  removeFeatureFlagsHandler(e) {
    this.featureFlagEventHandlers = this.featureFlagEventHandlers.filter(t => t !== e);
  }
  receivedFeatureFlags(e, i) {
    if (this.instance.persistence) {
      this.instance.decideEndpointWasHit = !0;
      var n = this.getFlagVariants(),
        s = this.getFlagPayloads();
      !function (e, i) {
        var n = arguments.length > 2 && void 0 !== arguments[2] ? arguments[2] : {},
          s = arguments.length > 3 && void 0 !== arguments[3] ? arguments[3] : {},
          r = e.featureFlags,
          o = e.featureFlagPayloads;
        if (r) if (I(r)) {
          var a = {};
          if (r) for (var l = 0; l < r.length; l++) a[r[l]] = !0;
          i && i.register({
            [Ne]: r,
            [Se]: a
          });
        } else {
          var u = r,
            c = o;
          e.errorsWhileComputingFlags && (u = t(t({}, n), u), c = t(t({}, s), c)), i && i.register({
            [Ne]: Object.keys(He(u)),
            [Se]: u || {},
            [Be]: c || {}
          });
        }
      }(e, this.instance.persistence, n, s), this._fireFeatureFlagsCallbacks(i);
    }
  }
  override(e) {
    var t = arguments.length > 1 && void 0 !== arguments[1] && arguments[1];
    if (!this.instance.__loaded || !this.instance.persistence) return B.uninitializedWarning("posthog.feature_flags.override");
    if (this._override_warning = t, !1 === e) this.instance.persistence.unregister(qe);else if (I(e)) {
      for (var i = {}, n = 0; n < e.length; n++) i[e[n]] = !0;
      this.instance.persistence.register({
        [qe]: i
      });
    } else this.instance.persistence.register({
      [qe]: e
    });
  }
  onFeatureFlags(e) {
    if (this.addFeatureFlagsHandler(e), this.instance.decideEndpointWasHit) {
      var {
        flags: t,
        flagVariants: i
      } = this._prepareFeatureFlagsForCallbacks();
      e(t, i);
    }
    return () => this.removeFeatureFlagsHandler(e);
  }
  updateEarlyAccessFeatureEnrollment(e, i) {
    var n,
      s = {
        ["$feature_enrollment/".concat(e)]: i
      };
    this.instance.capture("$feature_enrollment_update", {
      $feature_flag: e,
      $feature_enrollment: i,
      $set: s
    }), this.setPersonPropertiesForFlags(s, !1);
    var r = t(t({}, this.getFlagVariants()), {}, {
      [e]: i
    });
    null === (n = this.instance.persistence) || void 0 === n || n.register({
      [Ne]: Object.keys(He(r)),
      [Se]: r
    }), this._fireFeatureFlagsCallbacks();
  }
  getEarlyAccessFeatures(e) {
    var t = arguments.length > 1 && void 0 !== arguments[1] && arguments[1],
      i = this.instance.get_property(Ee);
    if (i && !t) return e(i);
    this.instance._send_request({
      transport: "XHR",
      url: this.instance.requestRouter.endpointFor("api", "/api/early_access_features/?token=".concat(this.instance.config.token)),
      method: "GET",
      callback: t => {
        var i;
        if (t.json) {
          var n = t.json.earlyAccessFeatures;
          return null === (i = this.instance.persistence) || void 0 === i || i.register({
            [Ee]: n
          }), e(n);
        }
      }
    });
  }
  _prepareFeatureFlagsForCallbacks() {
    var e = this.getFlags(),
      t = this.getFlagVariants();
    return {
      flags: e.filter(e => t[e]),
      flagVariants: Object.keys(t).filter(e => t[e]).reduce((e, i) => (e[i] = t[i], e), {})
    };
  }
  _fireFeatureFlagsCallbacks(e) {
    var {
      flags: t,
      flagVariants: i
    } = this._prepareFeatureFlagsForCallbacks();
    this.featureFlagEventHandlers.forEach(n => n(t, i, {
      errorsLoading: e
    }));
  }
  setPersonPropertiesForFlags(e) {
    var i = !(arguments.length > 1 && void 0 !== arguments[1]) || arguments[1],
      n = this.instance.get_property(ke) || {};
    this.instance.register({
      [ke]: t(t({}, n), e)
    }), i && this.instance.reloadFeatureFlags();
  }
  resetPersonPropertiesForFlags() {
    this.instance.unregister(ke);
  }
  setGroupPropertiesForFlags(e) {
    var i = !(arguments.length > 1 && void 0 !== arguments[1]) || arguments[1],
      n = this.instance.get_property(xe) || {};
    0 !== Object.keys(n).length && Object.keys(n).forEach(i => {
      n[i] = t(t({}, n[i]), e[i]), delete e[i];
    }), this.instance.register({
      [xe]: t(t({}, n), e)
    }), i && this.instance.reloadFeatureFlags();
  }
  resetGroupPropertiesForFlags(e) {
    if (e) {
      var i = this.instance.get_property(xe) || {};
      this.instance.register({
        [xe]: t(t({}, i), {}, {
          [e]: {}
        })
      });
    } else this.instance.unregister(xe);
  }
}
Math.trunc || (Math.trunc = function (e) {
  return e < 0 ? Math.ceil(e) : Math.floor(e);
}), Number.isInteger || (Number.isInteger = function (e) {
  return A(e) && isFinite(e) && Math.floor(e) === e;
});
var ze = "0123456789abcdef";
class We {
  constructor(e) {
    if (this.bytes = e, 16 !== e.length) throw new TypeError("not 128-bit length");
  }
  static fromFieldsV7(e, t, i, n) {
    if (!Number.isInteger(e) || !Number.isInteger(t) || !Number.isInteger(i) || !Number.isInteger(n) || e < 0 || t < 0 || i < 0 || n < 0 || e > 0xffffffffffff || t > 4095 || i > 1073741823 || n > 4294967295) throw new RangeError("invalid field value");
    var s = new Uint8Array(16);
    return s[0] = e / Math.pow(2, 40), s[1] = e / Math.pow(2, 32), s[2] = e / Math.pow(2, 24), s[3] = e / Math.pow(2, 16), s[4] = e / Math.pow(2, 8), s[5] = e, s[6] = 112 | t >>> 8, s[7] = t, s[8] = 128 | i >>> 24, s[9] = i >>> 16, s[10] = i >>> 8, s[11] = i, s[12] = n >>> 24, s[13] = n >>> 16, s[14] = n >>> 8, s[15] = n, new We(s);
  }
  toString() {
    for (var e = "", t = 0; t < this.bytes.length; t++) e = e + ze.charAt(this.bytes[t] >>> 4) + ze.charAt(15 & this.bytes[t]), 3 !== t && 5 !== t && 7 !== t && 9 !== t || (e += "-");
    if (36 !== e.length) throw new Error("Invalid UUIDv7 was generated");
    return e;
  }
  clone() {
    return new We(this.bytes.slice(0));
  }
  equals(e) {
    return 0 === this.compareTo(e);
  }
  compareTo(e) {
    for (var t = 0; t < 16; t++) {
      var i = this.bytes[t] - e.bytes[t];
      if (0 !== i) return Math.sign(i);
    }
    return 0;
  }
}
class je {
  constructor() {
    i(this, "timestamp", 0), i(this, "counter", 0), i(this, "random", new Je());
  }
  generate() {
    var e = this.generateOrAbort();
    if (F(e)) {
      this.timestamp = 0;
      var t = this.generateOrAbort();
      if (F(t)) throw new Error("Could not generate UUID after timestamp reset");
      return t;
    }
    return e;
  }
  generateOrAbort() {
    var e = Date.now();
    if (e > this.timestamp) this.timestamp = e, this.resetCounter();else {
      if (!(e + 1e4 > this.timestamp)) return;
      this.counter++, this.counter > 4398046511103 && (this.timestamp++, this.resetCounter());
    }
    return We.fromFieldsV7(this.timestamp, Math.trunc(this.counter / Math.pow(2, 30)), this.counter & Math.pow(2, 30) - 1, this.random.nextUint32());
  }
  resetCounter() {
    this.counter = 1024 * this.random.nextUint32() + (1023 & this.random.nextUint32());
  }
}
var Ge,
  Ve = e => {
    if ("undefined" != typeof UUIDV7_DENY_WEAK_RNG && UUIDV7_DENY_WEAK_RNG) throw new Error("no cryptographically strong RNG available");
    for (var t = 0; t < e.length; t++) e[t] = 65536 * Math.trunc(65536 * Math.random()) + Math.trunc(65536 * Math.random());
    return e;
  };
o && !F(o.crypto) && crypto.getRandomValues && (Ve = e => crypto.getRandomValues(e));
class Je {
  constructor() {
    i(this, "buffer", new Uint32Array(8)), i(this, "cursor", 1 / 0);
  }
  nextUint32() {
    return this.cursor >= this.buffer.length && (Ve(this.buffer), this.cursor = 0), this.buffer[this.cursor++];
  }
}
var Qe = () => Ye().toString(),
  Ye = () => (Ge || (Ge = new je())).generate(),
  Xe = "Thu, 01 Jan 1970 00:00:00 GMT",
  Ke = "";
var Ze = /[a-z0-9][a-z0-9-]+\.[a-z]{2,}$/i;
function et(e, t) {
  if (t) {
    var i = function (e) {
      var t = arguments.length > 1 && void 0 !== arguments[1] ? arguments[1] : h;
      if (Ke) return Ke;
      if (!t) return "";
      if (["localhost", "127.0.0.1"].includes(e)) return "";
      for (var i = e.split("."), n = Math.min(i.length, 8), s = "dmn_chk_" + Qe(), r = new RegExp("(^|;)\\s*" + s + "=1"); !Ke && n--;) {
        var o = i.slice(n).join("."),
          a = s + "=1;domain=." + o;
        t.cookie = a, r.test(t.cookie) && (t.cookie = a + ";expires=" + Xe, Ke = o);
      }
      return Ke;
    }(e);
    if (!i) {
      var n = (e => {
        var t = e.match(Ze);
        return t ? t[0] : "";
      })(e);
      n !== i && B.info("Warning: cookie subdomain discovery mismatch", n, i), i = n;
    }
    return i ? "; domain=." + i : "";
  }
  return "";
}
var tt = {
    is_supported: () => !!h,
    error: function (e) {
      B.error("cookieStore error: " + e);
    },
    get: function (e) {
      if (h) {
        try {
          for (var t = e + "=", i = h.cookie.split(";").filter(e => e.length), n = 0; n < i.length; n++) {
            for (var s = i[n]; " " == s.charAt(0);) s = s.substring(1, s.length);
            if (0 === s.indexOf(t)) return decodeURIComponent(s.substring(t.length, s.length));
          }
        } catch (e) {}
        return null;
      }
    },
    parse: function (e) {
      var t;
      try {
        t = JSON.parse(tt.get(e)) || {};
      } catch (e) {}
      return t;
    },
    set: function (e, t, i, n, s) {
      if (h) try {
        var r = "",
          o = "",
          a = et(h.location.hostname, n);
        if (i) {
          var l = new Date();
          l.setTime(l.getTime() + 24 * i * 60 * 60 * 1e3), r = "; expires=" + l.toUTCString();
        }
        s && (o = "; secure");
        var u = e + "=" + encodeURIComponent(JSON.stringify(t)) + r + "; SameSite=Lax; path=/" + a + o;
        return u.length > 3686.4 && B.warn("cookieStore warning: large cookie, len=" + u.length), h.cookie = u, u;
      } catch (e) {
        return;
      }
    },
    remove: function (e, t) {
      try {
        tt.set(e, "", -1, t);
      } catch (e) {
        return;
      }
    }
  },
  it = null,
  nt = {
    is_supported: function () {
      if (!O(it)) return it;
      var e = !0;
      if (F(o)) e = !1;else try {
        var t = "__mplssupport__";
        nt.set(t, "xyz"), '"xyz"' !== nt.get(t) && (e = !1), nt.remove(t);
      } catch (t) {
        e = !1;
      }
      return e || B.error("localStorage unsupported; falling back to cookie store"), it = e, e;
    },
    error: function (e) {
      B.error("localStorage error: " + e);
    },
    get: function (e) {
      try {
        return null == o ? void 0 : o.localStorage.getItem(e);
      } catch (e) {
        nt.error(e);
      }
      return null;
    },
    parse: function (e) {
      try {
        return JSON.parse(nt.get(e)) || {};
      } catch (e) {}
      return null;
    },
    set: function (e, t) {
      try {
        null == o || o.localStorage.setItem(e, JSON.stringify(t));
      } catch (e) {
        nt.error(e);
      }
    },
    remove: function (e) {
      try {
        null == o || o.localStorage.removeItem(e);
      } catch (e) {
        nt.error(e);
      }
    }
  },
  st = ["distinct_id", me, be, Ae, Me],
  rt = t(t({}, nt), {}, {
    parse: function (e) {
      try {
        var t = {};
        try {
          t = tt.parse(e) || {};
        } catch (e) {}
        var i = j(t, JSON.parse(nt.get(e) || "{}"));
        return nt.set(e, i), i;
      } catch (e) {}
      return null;
    },
    set: function (e, t, i, n, s, r) {
      try {
        nt.set(e, t, void 0, void 0, r);
        var o = {};
        st.forEach(e => {
          t[e] && (o[e] = t[e]);
        }), Object.keys(o).length && tt.set(e, o, i, n, s, r);
      } catch (e) {
        nt.error(e);
      }
    },
    remove: function (e, t) {
      try {
        null == o || o.localStorage.removeItem(e), tt.remove(e, t);
      } catch (e) {
        nt.error(e);
      }
    }
  }),
  ot = {},
  at = {
    is_supported: function () {
      return !0;
    },
    error: function (e) {
      B.error("memoryStorage error: " + e);
    },
    get: function (e) {
      return ot[e] || null;
    },
    parse: function (e) {
      return ot[e] || null;
    },
    set: function (e, t) {
      ot[e] = t;
    },
    remove: function (e) {
      delete ot[e];
    }
  },
  lt = null,
  ut = {
    is_supported: function () {
      if (!O(lt)) return lt;
      if (lt = !0, F(o)) lt = !1;else try {
        var e = "__support__";
        ut.set(e, "xyz"), '"xyz"' !== ut.get(e) && (lt = !1), ut.remove(e);
      } catch (e) {
        lt = !1;
      }
      return lt;
    },
    error: function (e) {
      B.error("sessionStorage error: ", e);
    },
    get: function (e) {
      try {
        return null == o ? void 0 : o.sessionStorage.getItem(e);
      } catch (e) {
        ut.error(e);
      }
      return null;
    },
    parse: function (e) {
      try {
        return JSON.parse(ut.get(e)) || null;
      } catch (e) {}
      return null;
    },
    set: function (e, t) {
      try {
        null == o || o.sessionStorage.setItem(e, JSON.stringify(t));
      } catch (e) {
        ut.error(e);
      }
    },
    remove: function (e) {
      try {
        null == o || o.sessionStorage.removeItem(e);
      } catch (e) {
        ut.error(e);
      }
    }
  },
  ct = ["localhost", "127.0.0.1"],
  dt = e => {
    var t = null == h ? void 0 : h.createElement("a");
    return F(t) ? null : (t.href = e, t);
  },
  ht = function (e, t) {
    return !!function (e) {
      try {
        new RegExp(e);
      } catch (e) {
        return !1;
      }
      return !0;
    }(t) && new RegExp(t).test(e);
  },
  _t = function (e) {
    var t,
      i,
      n = arguments.length > 1 && void 0 !== arguments[1] ? arguments[1] : "&",
      s = [];
    return W(e, function (e, n) {
      F(e) || F(n) || "undefined" === n || (t = encodeURIComponent((e => e instanceof File)(e) ? e.name : e.toString()), i = encodeURIComponent(n), s[s.length] = i + "=" + t);
    }), s.join(n);
  },
  pt = function (e, t) {
    for (var i, n = ((e.split("#")[0] || "").split("?")[1] || "").split("&"), s = 0; s < n.length; s++) {
      var r = n[s].split("=");
      if (r[0] === t) {
        i = r;
        break;
      }
    }
    if (!I(i) || i.length < 2) return "";
    var o = i[1];
    try {
      o = decodeURIComponent(o);
    } catch (e) {
      B.error("Skipping decoding for malformed query param: " + o);
    }
    return o.replace(/\+/g, " ");
  },
  vt = function (e, t) {
    var i = e.match(new RegExp(t + "=([^&]*)"));
    return i ? i[1] : null;
  },
  gt = "Mobile",
  ft = "iOS",
  mt = "Android",
  bt = "Tablet",
  yt = mt + " " + bt,
  wt = "iPad",
  St = "Apple",
  Et = St + " Watch",
  kt = "Safari",
  xt = "BlackBerry",
  It = "Samsung",
  Ct = It + "Browser",
  Pt = It + " Internet",
  Rt = "Chrome",
  Ft = Rt + " OS",
  Tt = Rt + " " + ft,
  $t = "Internet Explorer",
  Ot = $t + " " + gt,
  Mt = "Opera",
  At = Mt + " Mini",
  Lt = "Edge",
  Dt = "Microsoft " + Lt,
  Nt = "Firefox",
  qt = Nt + " " + ft,
  Bt = "Nintendo",
  Ht = "PlayStation",
  Ut = "Xbox",
  zt = mt + " " + gt,
  Wt = gt + " " + kt,
  jt = "Windows",
  Gt = jt + " Phone",
  Vt = "Nokia",
  Jt = "Ouya",
  Qt = "Generic",
  Yt = Qt + " " + gt.toLowerCase(),
  Xt = Qt + " " + bt.toLowerCase(),
  Kt = "Konqueror",
  Zt = "(\\d+(\\.\\d+)?)",
  ei = new RegExp("Version/" + Zt),
  ti = new RegExp(Ut, "i"),
  ii = new RegExp(Ht + " \\w+", "i"),
  ni = new RegExp(Bt + " \\w+", "i"),
  si = new RegExp(xt + "|PlayBook|BB10", "i"),
  ri = {
    "NT3.51": "NT 3.11",
    "NT4.0": "NT 4.0",
    "5.0": "2000",
    5.1: "XP",
    5.2: "XP",
    "6.0": "Vista",
    6.1: "7",
    6.2: "8",
    6.3: "8.1",
    6.4: "10",
    "10.0": "10"
  };
var oi = (e, t) => t && G(t, St) || function (e) {
    return G(e, kt) && !G(e, Rt) && !G(e, mt);
  }(e),
  ai = function (e, t) {
    return t = t || "", G(e, " OPR/") && G(e, "Mini") ? At : G(e, " OPR/") ? Mt : si.test(e) ? xt : G(e, "IE" + gt) || G(e, "WPDesktop") ? Ot : G(e, Ct) ? Pt : G(e, Lt) || G(e, "Edg/") ? Dt : G(e, "FBIOS") ? "Facebook " + gt : G(e, "UCWEB") || G(e, "UCBrowser") ? "UC Browser" : G(e, "CriOS") ? Tt : G(e, "CrMo") || G(e, Rt) ? Rt : G(e, mt) && G(e, kt) ? zt : G(e, "FxiOS") ? qt : G(e.toLowerCase(), Kt.toLowerCase()) ? Kt : oi(e, t) ? G(e, gt) ? Wt : kt : G(e, Nt) ? Nt : G(e, "MSIE") || G(e, "Trident/") ? $t : G(e, "Gecko") ? Nt : "";
  },
  li = {
    [Ot]: [new RegExp("rv:" + Zt)],
    [Dt]: [new RegExp(Lt + "?\\/" + Zt)],
    [Rt]: [new RegExp("(" + Rt + "|CrMo)\\/" + Zt)],
    [Tt]: [new RegExp("CriOS\\/" + Zt)],
    "UC Browser": [new RegExp("(UCBrowser|UCWEB)\\/" + Zt)],
    [kt]: [ei],
    [Wt]: [ei],
    [Mt]: [new RegExp("(Opera|OPR)\\/" + Zt)],
    [Nt]: [new RegExp(Nt + "\\/" + Zt)],
    [qt]: [new RegExp("FxiOS\\/" + Zt)],
    [Kt]: [new RegExp("Konqueror[:/]?" + Zt, "i")],
    [xt]: [new RegExp(xt + " " + Zt), ei],
    [zt]: [new RegExp("android\\s" + Zt, "i")],
    [Pt]: [new RegExp(Ct + "\\/" + Zt)],
    [$t]: [new RegExp("(rv:|MSIE )" + Zt)],
    Mozilla: [new RegExp("rv:" + Zt)]
  },
  ui = [[new RegExp(Ut + "; " + Ut + " (.*?)[);]", "i"), e => [Ut, e && e[1] || ""]], [new RegExp(Bt, "i"), [Bt, ""]], [new RegExp(Ht, "i"), [Ht, ""]], [si, [xt, ""]], [new RegExp(jt, "i"), (e, t) => {
    if (/Phone/.test(t) || /WPDesktop/.test(t)) return [Gt, ""];
    if (new RegExp(gt).test(t) && !/IEMobile\b/.test(t)) return [jt + " " + gt, ""];
    var i = /Windows NT ([0-9.]+)/i.exec(t);
    if (i && i[1]) {
      var n = i[1],
        s = ri[n] || "";
      return /arm/i.test(t) && (s = "RT"), [jt, s];
    }
    return [jt, ""];
  }], [/((iPhone|iPad|iPod).*?OS (\d+)_(\d+)_?(\d+)?|iPhone)/, e => {
    if (e && e[3]) {
      var t = [e[3], e[4], e[5] || "0"];
      return [ft, t.join(".")];
    }
    return [ft, ""];
  }], [/(watch.*\/(\d+\.\d+\.\d+)|watch os,(\d+\.\d+),)/i, e => {
    var t = "";
    return e && e.length >= 3 && (t = F(e[2]) ? e[3] : e[2]), ["watchOS", t];
  }], [new RegExp("(" + mt + " (\\d+)\\.(\\d+)\\.?(\\d+)?|" + mt + ")", "i"), e => {
    if (e && e[2]) {
      var t = [e[2], e[3], e[4] || "0"];
      return [mt, t.join(".")];
    }
    return [mt, ""];
  }], [/Mac OS X (\d+)[_.](\d+)[_.]?(\d+)?/i, e => {
    var t = ["Mac OS X", ""];
    if (e && e[1]) {
      var i = [e[1], e[2], e[3] || "0"];
      t[1] = i.join(".");
    }
    return t;
  }], [/Mac/i, ["Mac OS X", ""]], [/CrOS/, [Ft, ""]], [/Linux|debian/i, ["Linux", ""]]],
  ci = function (e) {
    return ni.test(e) ? Bt : ii.test(e) ? Ht : ti.test(e) ? Ut : new RegExp(Jt, "i").test(e) ? Jt : new RegExp("(" + Gt + "|WPDesktop)", "i").test(e) ? Gt : /iPad/.test(e) ? wt : /iPod/.test(e) ? "iPod Touch" : /iPhone/.test(e) ? "iPhone" : /(watch)(?: ?os[,/]|\d,\d\/)[\d.]+/i.test(e) ? Et : si.test(e) ? xt : /(kobo)\s(ereader|touch)/i.test(e) ? "Kobo" : new RegExp(Vt, "i").test(e) ? Vt : /(kf[a-z]{2}wi|aeo[c-r]{2})( bui|\))/i.test(e) || /(kf[a-z]+)( bui|\)).+silk\//i.test(e) ? "Kindle Fire" : /(Android|ZTE)/i.test(e) ? !new RegExp(gt).test(e) || /(9138B|TB782B|Nexus [97]|pixel c|HUAWEISHT|BTV|noble nook|smart ultra 6)/i.test(e) ? /pixel[\daxl ]{1,6}/i.test(e) && !/pixel c/i.test(e) || /(huaweimed-al00|tah-|APA|SM-G92|i980|zte|U304AA)/i.test(e) || /lmy47v/i.test(e) && !/QTAQZ3/i.test(e) ? mt : yt : mt : new RegExp("(pda|" + gt + ")", "i").test(e) ? Yt : new RegExp(bt, "i").test(e) && !new RegExp(bt + " pc", "i").test(e) ? Xt : "";
  },
  di = "https?://(.*)",
  hi = ["utm_source", "utm_medium", "utm_campaign", "utm_content", "utm_term", "gclid", "gad_source", "gclsrc", "dclid", "gbraid", "wbraid", "fbclid", "msclkid", "twclid", "li_fat_id", "mc_cid", "igshid", "ttclid", "rdt_cid"],
  _i = {
    campaignParams: function (e) {
      return h ? this._campaignParamsFromUrl(h.URL, e) : {};
    },
    _campaignParamsFromUrl: function (e, t) {
      var i = hi.concat(t || []),
        n = {};
      return W(i, function (t) {
        var i = pt(e, t);
        n[t] = i || null;
      }), n;
    },
    _searchEngine: function (e) {
      return e ? 0 === e.search(di + "google.([^/?]*)") ? "google" : 0 === e.search(di + "bing.com") ? "bing" : 0 === e.search(di + "yahoo.com") ? "yahoo" : 0 === e.search(di + "duckduckgo.com") ? "duckduckgo" : null : null;
    },
    _searchInfoFromReferrer: function (e) {
      var t = _i._searchEngine(e),
        i = "yahoo" != t ? "q" : "p",
        n = {};
      if (!O(t)) {
        n.$search_engine = t;
        var s = h ? pt(h.referrer, i) : "";
        s.length && (n.ph_keyword = s);
      }
      return n;
    },
    searchInfo: function () {
      var e = null == h ? void 0 : h.referrer;
      return e ? this._searchInfoFromReferrer(e) : {};
    },
    browser: ai,
    browserVersion: function (e, t) {
      var i = ai(e, t),
        n = li[i];
      if (F(n)) return null;
      for (var s = 0; s < n.length; s++) {
        var r = n[s],
          o = e.match(r);
        if (o) return parseFloat(o[o.length - 2]);
      }
      return null;
    },
    browserLanguage: function () {
      return navigator.language || navigator.userLanguage;
    },
    browserLanguagePrefix: function () {
      var e = this.browserLanguage();
      return "string" == typeof e ? e.split("-")[0] : void 0;
    },
    os: function (e) {
      for (var t = 0; t < ui.length; t++) {
        var [i, n] = ui[t],
          s = i.exec(e),
          r = s && (C(n) ? n(s, e) : n);
        if (r) return r;
      }
      return ["", ""];
    },
    device: ci,
    deviceType: function (e) {
      var t = ci(e);
      return t === wt || t === yt || "Kobo" === t || "Kindle Fire" === t || t === Xt ? bt : t === Bt || t === Ut || t === Ht || t === Jt ? "Console" : t === Et ? "Wearable" : t ? gt : "Desktop";
    },
    referrer: function () {
      return (null == h ? void 0 : h.referrer) || "$direct";
    },
    referringDomain: function () {
      var e;
      return null != h && h.referrer && (null === (e = dt(h.referrer)) || void 0 === e ? void 0 : e.host) || "$direct";
    },
    referrerInfo: function () {
      return {
        $referrer: this.referrer(),
        $referring_domain: this.referringDomain()
      };
    },
    initialPersonInfo: function () {
      return {
        r: this.referrer().substring(0, 1e3),
        u: null == _ ? void 0 : _.href.substring(0, 1e3)
      };
    },
    initialPersonPropsFromInfo: function (e) {
      var t,
        {
          r: i,
          u: n
        } = e,
        s = {
          $initial_referrer: i,
          $initial_referring_domain: null == i ? void 0 : "$direct" == i ? "$direct" : null === (t = dt(i)) || void 0 === t ? void 0 : t.host
        };
      if (n) {
        s.$initial_current_url = n;
        var r = dt(n);
        s.$initial_host = null == r ? void 0 : r.host, s.$initial_pathname = null == r ? void 0 : r.pathname, W(this._campaignParamsFromUrl(n), function (e, t) {
          s["$initial_" + X(t)] = e;
        });
      }
      i && W(this._searchInfoFromReferrer(i), function (e, t) {
        s["$initial_" + X(t)] = e;
      });
      return s;
    },
    timezone: function () {
      try {
        return Intl.DateTimeFormat().resolvedOptions().timeZone;
      } catch (e) {
        return;
      }
    },
    timezoneOffset: function () {
      try {
        return new Date().getTimezoneOffset();
      } catch (e) {
        return;
      }
    },
    properties: function () {
      if (!f) return {};
      var [e, t] = _i.os(f);
      return j(Y({
        $os: e,
        $os_version: t,
        $browser: _i.browser(f, navigator.vendor),
        $device: _i.device(f),
        $device_type: _i.deviceType(f),
        $timezone: _i.timezone(),
        $timezone_offset: _i.timezoneOffset()
      }), {
        $current_url: null == _ ? void 0 : _.href,
        $host: null == _ ? void 0 : _.host,
        $pathname: null == _ ? void 0 : _.pathname,
        $raw_user_agent: f.length > 1e3 ? f.substring(0, 997) + "..." : f,
        $browser_version: _i.browserVersion(f, navigator.vendor),
        $browser_language: _i.browserLanguage(),
        $browser_language_prefix: _i.browserLanguagePrefix(),
        $screen_height: null == o ? void 0 : o.screen.height,
        $screen_width: null == o ? void 0 : o.screen.width,
        $viewport_height: null == o ? void 0 : o.innerHeight,
        $viewport_width: null == o ? void 0 : o.innerWidth,
        $lib: "web",
        $lib_version: r.LIB_VERSION,
        $insert_id: Math.random().toString(36).substring(2, 10) + Math.random().toString(36).substring(2, 10),
        $time: Date.now() / 1e3
      });
    },
    people_properties: function () {
      if (!f) return {};
      var [e, t] = _i.os(f);
      return j(Y({
        $os: e,
        $os_version: t,
        $browser: _i.browser(f, navigator.vendor)
      }), {
        $browser_version: _i.browserVersion(f, navigator.vendor)
      });
    }
  },
  pi = ["cookie", "localstorage", "localstorage+cookie", "sessionstorage", "memory"];
class vi {
  constructor(e) {
    this.config = e, this.props = {}, this.campaign_params_saved = !1, this.name = (e => {
      var t = "";
      return e.token && (t = e.token.replace(/\+/g, "PL").replace(/\//g, "SL").replace(/=/g, "EQ")), e.persistence_name ? "ph_" + e.persistence_name : "ph_" + t + "_posthog";
    })(e), this.storage = this.buildStorage(e), this.load(), e.debug && B.info("Persistence loaded", e.persistence, t({}, this.props)), this.update_config(e, e), this.save();
  }
  buildStorage(e) {
    -1 === pi.indexOf(e.persistence.toLowerCase()) && (B.critical("Unknown persistence type " + e.persistence + "; falling back to localStorage+cookie"), e.persistence = "localStorage+cookie");
    var t = e.persistence.toLowerCase();
    return "localstorage" === t && nt.is_supported() ? nt : "localstorage+cookie" === t && rt.is_supported() ? rt : "sessionstorage" === t && ut.is_supported() ? ut : "memory" === t ? at : "cookie" === t ? tt : rt.is_supported() ? rt : tt;
  }
  properties() {
    var e = {};
    return W(this.props, function (t, i) {
      if (i === Se && P(t)) for (var n = Object.keys(t), s = 0; s < n.length; s++) e["$feature/".concat(n[s])] = t[n[s]];else o = i, a = !1, (O(r = De) ? a : c && r.indexOf === c ? -1 != r.indexOf(o) : (W(r, function (e) {
        if (a || (a = e === o)) return H;
      }), a)) || (e[i] = t);
      var r, o, a;
    }), e;
  }
  load() {
    if (!this.disabled) {
      var e = this.storage.parse(this.name);
      e && (this.props = j({}, e));
    }
  }
  save() {
    this.disabled || this.storage.set(this.name, this.props, this.expire_days, this.cross_subdomain, this.secure, this.config.debug);
  }
  remove() {
    this.storage.remove(this.name, !1), this.storage.remove(this.name, !0);
  }
  clear() {
    this.remove(), this.props = {};
  }
  register_once(e, t, i) {
    if (P(e)) {
      F(t) && (t = "None"), this.expire_days = F(i) ? this.default_expiry : i;
      var n = !1;
      if (W(e, (e, i) => {
        this.props.hasOwnProperty(i) && this.props[i] !== t || (this.props[i] = e, n = !0);
      }), n) return this.save(), !0;
    }
    return !1;
  }
  register(e, t) {
    if (P(e)) {
      this.expire_days = F(t) ? this.default_expiry : t;
      var i = !1;
      if (W(e, (t, n) => {
        e.hasOwnProperty(n) && this.props[n] !== t && (this.props[n] = t, i = !0);
      }), i) return this.save(), !0;
    }
    return !1;
  }
  unregister(e) {
    e in this.props && (delete this.props[e], this.save());
  }
  update_campaign_params() {
    if (!this.campaign_params_saved) {
      var e = _i.campaignParams(this.config.custom_campaign_params);
      R(Y(e)) || this.register(e), this.campaign_params_saved = !0;
    }
  }
  update_search_keyword() {
    this.register(_i.searchInfo());
  }
  update_referrer_info() {
    this.register_once(_i.referrerInfo(), void 0);
  }
  set_initial_person_info() {
    this.props[$e] || this.props[Oe] || this.register_once({
      [Me]: _i.initialPersonInfo()
    }, void 0);
  }
  get_referrer_info() {
    return Y({
      $referrer: this.props.$referrer,
      $referring_domain: this.props.$referring_domain
    });
  }
  get_initial_props() {
    var e = {};
    W([Oe, $e], t => {
      var i = this.props[t];
      i && W(i, function (t, i) {
        e["$initial_" + X(i)] = t;
      });
    });
    var t = this.props[Me];
    if (t) {
      var i = _i.initialPersonPropsFromInfo(t);
      j(e, i);
    }
    return e;
  }
  safe_merge(e) {
    return W(this.props, function (t, i) {
      i in e || (e[i] = t);
    }), e;
  }
  update_config(e, t) {
    if (this.default_expiry = this.expire_days = e.cookie_expiration, this.set_disabled(e.disable_persistence), this.set_cross_subdomain(e.cross_subdomain_cookie), this.set_secure(e.secure_cookie), e.persistence !== t.persistence) {
      var i = this.buildStorage(e),
        n = this.props;
      this.clear(), this.storage = i, this.props = n, this.save();
    }
  }
  set_disabled(e) {
    this.disabled = e, this.disabled ? this.remove() : this.save();
  }
  set_cross_subdomain(e) {
    e !== this.cross_subdomain && (this.cross_subdomain = e, this.remove(), this.save());
  }
  get_cross_subdomain() {
    return !!this.cross_subdomain;
  }
  set_secure(e) {
    e !== this.secure && (this.secure = e, this.remove(), this.save());
  }
  set_event_timer(e, t) {
    var i = this.props[se] || {};
    i[e] = t, this.props[se] = i, this.save();
  }
  remove_event_timer(e) {
    var t = (this.props[se] || {})[e];
    return F(t) || (delete this.props[se][e], this.save()), t;
  }
  get_property(e) {
    return this.props[e];
  }
  set_property(e, t) {
    this.props[e] = t, this.save();
  }
}
function gi(e) {
  var t, i;
  return (null === (t = JSON.stringify(e, (i = [], function (e, t) {
    if (P(t)) {
      for (; i.length > 0 && i[i.length - 1] !== this;) i.pop();
      return i.includes(t) ? "[Circular]" : (i.push(t), t);
    }
    return t;
  }))) || void 0 === t ? void 0 : t.length) || 0;
}
function fi(e) {
  var t = arguments.length > 1 && void 0 !== arguments[1] ? arguments[1] : 6606028.8;
  if (e.size >= t && e.data.length > 1) {
    var i = Math.floor(e.data.length / 2),
      n = e.data.slice(0, i),
      s = e.data.slice(i);
    return [fi({
      size: gi(n),
      data: n,
      sessionId: e.sessionId,
      windowId: e.windowId
    }), fi({
      size: gi(s),
      data: s,
      sessionId: e.sessionId,
      windowId: e.windowId
    })].flatMap(e => e);
  }
  return [e];
}
var mi = (e => (e[e.DomContentLoaded = 0] = "DomContentLoaded", e[e.Load = 1] = "Load", e[e.FullSnapshot = 2] = "FullSnapshot", e[e.IncrementalSnapshot = 3] = "IncrementalSnapshot", e[e.Meta = 4] = "Meta", e[e.Custom = 5] = "Custom", e[e.Plugin = 6] = "Plugin", e))(mi || {}),
  bi = (e => (e[e.Mutation = 0] = "Mutation", e[e.MouseMove = 1] = "MouseMove", e[e.MouseInteraction = 2] = "MouseInteraction", e[e.Scroll = 3] = "Scroll", e[e.ViewportResize = 4] = "ViewportResize", e[e.Input = 5] = "Input", e[e.TouchMove = 6] = "TouchMove", e[e.MediaInteraction = 7] = "MediaInteraction", e[e.StyleSheetRule = 8] = "StyleSheetRule", e[e.CanvasMutation = 9] = "CanvasMutation", e[e.Font = 10] = "Font", e[e.Log = 11] = "Log", e[e.Drag = 12] = "Drag", e[e.StyleDeclaration = 13] = "StyleDeclaration", e[e.Selection = 14] = "Selection", e[e.AdoptedStyleSheet = 15] = "AdoptedStyleSheet", e[e.CustomElement = 16] = "CustomElement", e))(bi || {});
function yi(e) {
  var t;
  return e.id === Le || !(null === (t = e.closest) || void 0 === t || !t.call(e, ".toolbar-global-fade-container"));
}
function wi(e) {
  return !!e && 1 === e.nodeType;
}
function Si(e, t) {
  return !!e && !!e.tagName && e.tagName.toLowerCase() === t.toLowerCase();
}
function Ei(e) {
  return !!e && 3 === e.nodeType;
}
function ki(e) {
  return !!e && 11 === e.nodeType;
}
function xi(e) {
  return e ? U(e).split(/\s+/) : [];
}
function Ii(e) {
  var t = null == o ? void 0 : o.location.href;
  return !!(t && e && e.some(e => t.match(e)));
}
function Ci(e) {
  var t = "";
  switch (typeof e.className) {
    case "string":
      t = e.className;
      break;
    case "object":
      t = (e.className && "baseVal" in e.className ? e.className.baseVal : null) || e.getAttribute("class") || "";
      break;
    default:
      t = "";
  }
  return xi(t);
}
function Pi(e) {
  return M(e) ? null : U(e).split(/(\s+)/).filter(e => Ui(e)).join("").replace(/[\r\n]/g, " ").replace(/[ ]+/g, " ").substring(0, 255);
}
function Ri(e) {
  var t = "";
  return Mi(e) && !Ai(e) && e.childNodes && e.childNodes.length && W(e.childNodes, function (e) {
    var i;
    Ei(e) && e.textContent && (t += null !== (i = Pi(e.textContent)) && void 0 !== i ? i : "");
  }), U(t);
}
function Fi(e) {
  return F(e.target) ? e.srcElement || null : null !== (t = e.target) && void 0 !== t && t.shadowRoot ? e.composedPath()[0] || null : e.target || null;
  var t;
}
var Ti = ["a", "button", "form", "input", "select", "textarea", "label"];
function $i(e) {
  var t = e.parentNode;
  return !(!t || !wi(t)) && t;
}
function Oi(e, t) {
  var i = arguments.length > 2 && void 0 !== arguments[2] ? arguments[2] : void 0,
    n = arguments.length > 3 ? arguments[3] : void 0,
    s = arguments.length > 4 ? arguments[4] : void 0;
  if (!o || !e || Si(e, "html") || !wi(e)) return !1;
  if (null != i && i.url_allowlist && !Ii(i.url_allowlist)) return !1;
  if (null != i && i.url_ignorelist && Ii(i.url_ignorelist)) return !1;
  if (null != i && i.dom_event_allowlist) {
    var r = i.dom_event_allowlist;
    if (r && !r.some(e => t.type === e)) return !1;
  }
  for (var a = !1, l = [e], u = !0, c = e; c.parentNode && !Si(c, "body");) if (ki(c.parentNode)) l.push(c.parentNode.host), c = c.parentNode.host;else {
    if (!(u = $i(c))) break;
    if (n || Ti.indexOf(u.tagName.toLowerCase()) > -1) a = !0;else {
      var d = o.getComputedStyle(u);
      d && "pointer" === d.getPropertyValue("cursor") && (a = !0);
    }
    l.push(u), c = u;
  }
  if (!function (e, t) {
    var i = null == t ? void 0 : t.element_allowlist;
    if (F(i)) return !0;
    var n = function (e) {
      if (i.some(t => e.tagName.toLowerCase() === t)) return {
        v: !0
      };
    };
    for (var s of e) {
      var r = n(s);
      if ("object" == typeof r) return r.v;
    }
    return !1;
  }(l, i)) return !1;
  if (!function (e, t) {
    var i = null == t ? void 0 : t.css_selector_allowlist;
    if (F(i)) return !0;
    var n = function (e) {
      if (i.some(t => e.matches(t))) return {
        v: !0
      };
    };
    for (var s of e) {
      var r = n(s);
      if ("object" == typeof r) return r.v;
    }
    return !1;
  }(l, i)) return !1;
  var h = o.getComputedStyle(e);
  if (h && "pointer" === h.getPropertyValue("cursor") && "click" === t.type) return !0;
  var _ = e.tagName.toLowerCase();
  switch (_) {
    case "html":
      return !1;
    case "form":
      return (s || ["submit"]).indexOf(t.type) >= 0;
    case "input":
    case "select":
    case "textarea":
      return (s || ["change", "click"]).indexOf(t.type) >= 0;
    default:
      return a ? (s || ["click"]).indexOf(t.type) >= 0 : (s || ["click"]).indexOf(t.type) >= 0 && (Ti.indexOf(_) > -1 || "true" === e.getAttribute("contenteditable"));
  }
}
function Mi(e) {
  for (var t = e; t.parentNode && !Si(t, "body"); t = t.parentNode) {
    var i = Ci(t);
    if (G(i, "ph-sensitive") || G(i, "ph-no-capture")) return !1;
  }
  if (G(Ci(e), "ph-include")) return !0;
  var n = e.type || "";
  if (T(n)) switch (n.toLowerCase()) {
    case "hidden":
    case "password":
      return !1;
  }
  var s = e.name || e.id || "";
  if (T(s)) {
    if (/^cc|cardnum|ccnum|creditcard|csc|cvc|cvv|exp|pass|pwd|routing|seccode|securitycode|securitynum|socialsec|socsec|ssn/i.test(s.replace(/[^a-zA-Z0-9]/g, ""))) return !1;
  }
  return !0;
}
function Ai(e) {
  return !!(Si(e, "input") && !["button", "checkbox", "submit", "reset"].includes(e.type) || Si(e, "select") || Si(e, "textarea") || "true" === e.getAttribute("contenteditable"));
}
var Li = "(4[0-9]{12}(?:[0-9]{3})?)|(5[1-5][0-9]{14})|(6(?:011|5[0-9]{2})[0-9]{12})|(3[47][0-9]{13})|(3(?:0[0-5]|[68][0-9])[0-9]{11})|((?:2131|1800|35[0-9]{3})[0-9]{11})",
  Di = new RegExp("^(?:".concat(Li, ")$")),
  Ni = new RegExp(Li),
  qi = "\\d{3}-?\\d{2}-?\\d{4}",
  Bi = new RegExp("^(".concat(qi, ")$")),
  Hi = new RegExp("(".concat(qi, ")"));
function Ui(e) {
  var t = !(arguments.length > 1 && void 0 !== arguments[1]) || arguments[1];
  if (M(e)) return !1;
  if (T(e)) {
    if (e = U(e), (t ? Di : Ni).test((e || "").replace(/[- ]/g, ""))) return !1;
    if ((t ? Bi : Hi).test(e)) return !1;
  }
  return !0;
}
function zi(e) {
  var t = Ri(e);
  return Ui(t = "".concat(t, " ").concat(Wi(e)).trim()) ? t : "";
}
function Wi(e) {
  var t = "";
  return e && e.childNodes && e.childNodes.length && W(e.childNodes, function (e) {
    var i;
    if (e && "span" === (null === (i = e.tagName) || void 0 === i ? void 0 : i.toLowerCase())) try {
      var n = Ri(e);
      t = "".concat(t, " ").concat(n).trim(), e.childNodes && e.childNodes.length && (t = "".concat(t, " ").concat(Wi(e)).trim());
    } catch (e) {
      B.error(e);
    }
  }), t;
}
function ji(e) {
  return function (e) {
    var i = e.map(e => {
      var i,
        n,
        s = "";
      if (e.tag_name && (s += e.tag_name), e.attr_class) for (var r of (e.attr_class.sort(), e.attr_class)) s += ".".concat(r.replace(/"/g, ""));
      var o = t(t(t(t({}, e.text ? {
          text: e.text
        } : {}), {}, {
          "nth-child": null !== (i = e.nth_child) && void 0 !== i ? i : 0,
          "nth-of-type": null !== (n = e.nth_of_type) && void 0 !== n ? n : 0
        }, e.href ? {
          href: e.href
        } : {}), e.attr_id ? {
          attr_id: e.attr_id
        } : {}), e.attributes),
        a = {};
      return V(o).sort((e, t) => {
        var [i] = e,
          [n] = t;
        return i.localeCompare(n);
      }).forEach(e => {
        var [t, i] = e;
        return a[Gi(t.toString())] = Gi(i.toString());
      }), s += ":", s += V(o).map(e => {
        var [t, i] = e;
        return "".concat(t, '="').concat(i, '"');
      }).join("");
    });
    return i.join(";");
  }(function (e) {
    return e.map(e => {
      var t,
        i,
        n = {
          text: null === (t = e.$el_text) || void 0 === t ? void 0 : t.slice(0, 400),
          tag_name: e.tag_name,
          href: null === (i = e.attr__href) || void 0 === i ? void 0 : i.slice(0, 2048),
          attr_class: Vi(e),
          attr_id: e.attr__id,
          nth_child: e.nth_child,
          nth_of_type: e.nth_of_type,
          attributes: {}
        };
      return V(e).filter(e => {
        var [t] = e;
        return 0 === t.indexOf("attr__");
      }).forEach(e => {
        var [t, i] = e;
        return n.attributes[t] = i;
      }), n;
    });
  }(e));
}
function Gi(e) {
  return e.replace(/"|\\"/g, '\\"');
}
function Vi(e) {
  var t = e.attr__class;
  return t ? I(t) ? t : xi(t) : void 0;
}
var Ji = "[SessionRecording]",
  Qi = "redacted",
  Yi = {
    initiatorTypes: ["audio", "beacon", "body", "css", "early-hint", "embed", "fetch", "frame", "iframe", "icon", "image", "img", "input", "link", "navigation", "object", "ping", "script", "track", "video", "xmlhttprequest"],
    maskRequestFn: e => e,
    recordHeaders: !1,
    recordBody: !1,
    recordInitialRequests: !1,
    recordPerformance: !1,
    performanceEntryTypeToObserve: ["first-input", "navigation", "paint", "resource"],
    payloadSizeLimitBytes: 1e6,
    payloadHostDenyList: [".lr-ingest.io", ".ingest.sentry.io"]
  },
  Xi = ["authorization", "x-forwarded-for", "authorization", "cookie", "set-cookie", "x-api-key", "x-real-ip", "remote-addr", "forwarded", "proxy-authorization", "x-csrf-token", "x-csrftoken", "x-xsrf-token"],
  Ki = ["password", "secret", "passwd", "api_key", "apikey", "auth", "credentials", "mysql_pwd", "privatekey", "private_key", "token"],
  Zi = ["/s/", "/e/", "/i/"];
function en(e, t, i, n) {
  if (M(e)) return e;
  var s = (null == t ? void 0 : t["content-length"]) || function (e) {
    return new Blob([e]).size;
  }(e);
  return T(s) && (s = parseInt(s)), s > i ? Ji + " ".concat(n, " body too large to record (").concat(s, " bytes)") : e;
}
function tn(e, t) {
  if (M(e)) return e;
  var i = e;
  return Ui(i, !1) || (i = Ji + " " + t + " body " + Qi), W(Ki, e => {
    var n, s;
    null !== (n = i) && void 0 !== n && n.length && -1 !== (null === (s = i) || void 0 === s ? void 0 : s.indexOf(e)) && (i = Ji + " " + t + " body " + Qi + " as might contain: " + e);
  }), i;
}
var nn = (e, i) => {
  var n,
    s,
    r,
    o = {
      payloadSizeLimitBytes: Yi.payloadSizeLimitBytes,
      performanceEntryTypeToObserve: [...Yi.performanceEntryTypeToObserve],
      payloadHostDenyList: [...(i.payloadHostDenyList || []), ...Yi.payloadHostDenyList]
    },
    a = !1 !== e.session_recording.recordHeaders && i.recordHeaders,
    l = !1 !== e.session_recording.recordBody && i.recordBody,
    u = !1 !== e.capture_performance && i.recordPerformance,
    c = (n = o, r = Math.min(1e6, null !== (s = n.payloadSizeLimitBytes) && void 0 !== s ? s : 1e6), e => (null != e && e.requestBody && (e.requestBody = en(e.requestBody, e.requestHeaders, r, "Request")), null != e && e.responseBody && (e.responseBody = en(e.responseBody, e.responseHeaders, r, "Response")), e)),
    d = t => {
      return c(((e, t) => {
        var i,
          n = dt(e.name),
          s = 0 === t.indexOf("http") ? null === (i = dt(t)) || void 0 === i ? void 0 : i.pathname : t;
        "/" === s && (s = "");
        var r = null == n ? void 0 : n.pathname.replace(s || "", "");
        if (!(n && r && Zi.some(e => 0 === r.indexOf(e)))) return e;
      })((n = (i = t).requestHeaders, M(n) || W(Object.keys(null != n ? n : {}), e => {
        Xi.includes(e.toLowerCase()) && (n[e] = Qi);
      }), i), e.api_host));
      var i, n;
    },
    h = C(e.session_recording.maskNetworkRequestFn);
  return h && C(e.session_recording.maskCapturedNetworkRequestFn) && B.warn("Both `maskNetworkRequestFn` and `maskCapturedNetworkRequestFn` are defined. `maskNetworkRequestFn` will be ignored."), h && (e.session_recording.maskCapturedNetworkRequestFn = i => {
    var n = e.session_recording.maskNetworkRequestFn({
      url: i.name
    });
    return t(t({}, i), {}, {
      name: null == n ? void 0 : n.url
    });
  }), o.maskRequestFn = C(e.session_recording.maskCapturedNetworkRequestFn) ? t => {
    var i,
      n,
      s,
      r = d(t);
    return r && null !== (i = null === (n = (s = e.session_recording).maskCapturedNetworkRequestFn) || void 0 === n ? void 0 : n.call(s, r)) && void 0 !== i ? i : void 0;
  } : e => function (e) {
    if (!F(e)) return e.requestBody = tn(e.requestBody, "Request"), e.responseBody = tn(e.responseBody, "Response"), e;
  }(d(e)), t(t(t({}, Yi), o), {}, {
    recordHeaders: a,
    recordBody: l,
    recordPerformance: u,
    recordInitialRequests: u
  });
};
function sn(e, t, i, n, s) {
  return t > i && (B.warn("min cannot be greater than max."), t = i), A(e) ? e > i ? (n && B.warn(n + " cannot be  greater than max: " + i + ". Using max value instead."), i) : e < t ? (n && B.warn(n + " cannot be less than min: " + t + ". Using min value instead."), t) : e : (n && B.warn(n + " must be a number. using max or fallback. max: " + i + ", fallback: " + s), sn(s || i, t, i, n));
}
class rn {
  constructor(e) {
    var t,
      n,
      s = arguments.length > 1 && void 0 !== arguments[1] ? arguments[1] : {};
    i(this, "bucketSize", 100), i(this, "refillRate", 10), i(this, "mutationBuckets", {}), i(this, "loggedTracker", {}), i(this, "refillBuckets", () => {
      Object.keys(this.mutationBuckets).forEach(e => {
        this.mutationBuckets[e] = this.mutationBuckets[e] + this.refillRate, this.mutationBuckets[e] >= this.bucketSize && delete this.mutationBuckets[e];
      });
    }), i(this, "getNodeOrRelevantParent", e => {
      var t = this.rrweb.mirror.getNode(e);
      if ("svg" !== (null == t ? void 0 : t.nodeName) && t instanceof Element) {
        var i = t.closest("svg");
        if (i) return [this.rrweb.mirror.getId(i), i];
      }
      return [e, t];
    }), i(this, "numberOfChanges", e => {
      var t, i, n, s, r, o, a, l;
      return (null !== (t = null === (i = e.removes) || void 0 === i ? void 0 : i.length) && void 0 !== t ? t : 0) + (null !== (n = null === (s = e.attributes) || void 0 === s ? void 0 : s.length) && void 0 !== n ? n : 0) + (null !== (r = null === (o = e.texts) || void 0 === o ? void 0 : o.length) && void 0 !== r ? r : 0) + (null !== (a = null === (l = e.adds) || void 0 === l ? void 0 : l.length) && void 0 !== a ? a : 0);
    }), i(this, "throttleMutations", e => {
      if (3 !== e.type || 0 !== e.data.source) return e;
      var t = e.data,
        i = this.numberOfChanges(t);
      t.attributes && (t.attributes = t.attributes.filter(e => {
        var t,
          i,
          n,
          [s, r] = this.getNodeOrRelevantParent(e.id);
        if (0 === this.mutationBuckets[s]) return !1;
        (this.mutationBuckets[s] = null !== (t = this.mutationBuckets[s]) && void 0 !== t ? t : this.bucketSize, this.mutationBuckets[s] = Math.max(this.mutationBuckets[s] - 1, 0), 0 === this.mutationBuckets[s]) && (this.loggedTracker[s] || (this.loggedTracker[s] = !0, null === (i = (n = this.options).onBlockedNode) || void 0 === i || i.call(n, s, r)));
        return e;
      }));
      var n = this.numberOfChanges(t);
      return 0 !== n || i === n ? e : void 0;
    }), this.rrweb = e, this.options = s, this.refillRate = sn(null !== (t = this.options.refillRate) && void 0 !== t ? t : this.refillRate, 0, 100, "mutation throttling refill rate"), this.bucketSize = sn(null !== (n = this.options.bucketSize) && void 0 !== n ? n : this.bucketSize, 0, 100, "mutation throttling bucket size"), setInterval(() => {
      this.refillBuckets();
    }, 1e3);
  }
}
var on = Uint8Array,
  an = Uint16Array,
  ln = Uint32Array,
  un = new on([0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 4, 4, 4, 4, 5, 5, 5, 5, 0, 0, 0, 0]),
  cn = new on([0, 0, 0, 0, 1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6, 7, 7, 8, 8, 9, 9, 10, 10, 11, 11, 12, 12, 13, 13, 0, 0]),
  dn = new on([16, 17, 18, 0, 8, 7, 9, 6, 10, 5, 11, 4, 12, 3, 13, 2, 14, 1, 15]),
  hn = function (e, t) {
    for (var i = new an(31), n = 0; n < 31; ++n) i[n] = t += 1 << e[n - 1];
    var s = new ln(i[30]);
    for (n = 1; n < 30; ++n) for (var r = i[n]; r < i[n + 1]; ++r) s[r] = r - i[n] << 5 | n;
    return [i, s];
  },
  _n = hn(un, 2),
  pn = _n[0],
  vn = _n[1];
pn[28] = 258, vn[258] = 28;
for (var gn = hn(cn, 0)[1], fn = new an(32768), mn = 0; mn < 32768; ++mn) {
  var bn = (43690 & mn) >>> 1 | (21845 & mn) << 1;
  bn = (61680 & (bn = (52428 & bn) >>> 2 | (13107 & bn) << 2)) >>> 4 | (3855 & bn) << 4, fn[mn] = ((65280 & bn) >>> 8 | (255 & bn) << 8) >>> 1;
}
var yn = function (e, t, i) {
    for (var n = e.length, s = 0, r = new an(t); s < n; ++s) ++r[e[s] - 1];
    var o,
      a = new an(t);
    for (s = 0; s < t; ++s) a[s] = a[s - 1] + r[s - 1] << 1;
    if (i) {
      o = new an(1 << t);
      var l = 15 - t;
      for (s = 0; s < n; ++s) if (e[s]) for (var u = s << 4 | e[s], c = t - e[s], d = a[e[s] - 1]++ << c, h = d | (1 << c) - 1; d <= h; ++d) o[fn[d] >>> l] = u;
    } else for (o = new an(n), s = 0; s < n; ++s) o[s] = fn[a[e[s] - 1]++] >>> 15 - e[s];
    return o;
  },
  wn = new on(288);
for (mn = 0; mn < 144; ++mn) wn[mn] = 8;
for (mn = 144; mn < 256; ++mn) wn[mn] = 9;
for (mn = 256; mn < 280; ++mn) wn[mn] = 7;
for (mn = 280; mn < 288; ++mn) wn[mn] = 8;
var Sn = new on(32);
for (mn = 0; mn < 32; ++mn) Sn[mn] = 5;
var En = yn(wn, 9, 0),
  kn = yn(Sn, 5, 0),
  xn = function (e) {
    return (e / 8 >> 0) + (7 & e && 1);
  },
  In = function (e, t, i) {
    (null == i || i > e.length) && (i = e.length);
    var n = new (e instanceof an ? an : e instanceof ln ? ln : on)(i - t);
    return n.set(e.subarray(t, i)), n;
  },
  Cn = function (e, t, i) {
    i <<= 7 & t;
    var n = t / 8 >> 0;
    e[n] |= i, e[n + 1] |= i >>> 8;
  },
  Pn = function (e, t, i) {
    i <<= 7 & t;
    var n = t / 8 >> 0;
    e[n] |= i, e[n + 1] |= i >>> 8, e[n + 2] |= i >>> 16;
  },
  Rn = function (e, t) {
    for (var i = [], n = 0; n < e.length; ++n) e[n] && i.push({
      s: n,
      f: e[n]
    });
    var s = i.length,
      r = i.slice();
    if (!s) return [new on(0), 0];
    if (1 == s) {
      var o = new on(i[0].s + 1);
      return o[i[0].s] = 1, [o, 1];
    }
    i.sort(function (e, t) {
      return e.f - t.f;
    }), i.push({
      s: -1,
      f: 25001
    });
    var a = i[0],
      l = i[1],
      u = 0,
      c = 1,
      d = 2;
    for (i[0] = {
      s: -1,
      f: a.f + l.f,
      l: a,
      r: l
    }; c != s - 1;) a = i[i[u].f < i[d].f ? u++ : d++], l = i[u != c && i[u].f < i[d].f ? u++ : d++], i[c++] = {
      s: -1,
      f: a.f + l.f,
      l: a,
      r: l
    };
    var h = r[0].s;
    for (n = 1; n < s; ++n) r[n].s > h && (h = r[n].s);
    var _ = new an(h + 1),
      p = Fn(i[c - 1], _, 0);
    if (p > t) {
      n = 0;
      var v = 0,
        g = p - t,
        f = 1 << g;
      for (r.sort(function (e, t) {
        return _[t.s] - _[e.s] || e.f - t.f;
      }); n < s; ++n) {
        var m = r[n].s;
        if (!(_[m] > t)) break;
        v += f - (1 << p - _[m]), _[m] = t;
      }
      for (v >>>= g; v > 0;) {
        var b = r[n].s;
        _[b] < t ? v -= 1 << t - _[b]++ - 1 : ++n;
      }
      for (; n >= 0 && v; --n) {
        var y = r[n].s;
        _[y] == t && (--_[y], ++v);
      }
      p = t;
    }
    return [new on(_), p];
  },
  Fn = function (e, t, i) {
    return -1 == e.s ? Math.max(Fn(e.l, t, i + 1), Fn(e.r, t, i + 1)) : t[e.s] = i;
  },
  Tn = function (e) {
    for (var t = e.length; t && !e[--t];);
    for (var i = new an(++t), n = 0, s = e[0], r = 1, o = function (e) {
        i[n++] = e;
      }, a = 1; a <= t; ++a) if (e[a] == s && a != t) ++r;else {
      if (!s && r > 2) {
        for (; r > 138; r -= 138) o(32754);
        r > 2 && (o(r > 10 ? r - 11 << 5 | 28690 : r - 3 << 5 | 12305), r = 0);
      } else if (r > 3) {
        for (o(s), --r; r > 6; r -= 6) o(8304);
        r > 2 && (o(r - 3 << 5 | 8208), r = 0);
      }
      for (; r--;) o(s);
      r = 1, s = e[a];
    }
    return [i.subarray(0, n), t];
  },
  $n = function (e, t) {
    for (var i = 0, n = 0; n < t.length; ++n) i += e[n] * t[n];
    return i;
  },
  On = function (e, t, i) {
    var n = i.length,
      s = xn(t + 2);
    e[s] = 255 & n, e[s + 1] = n >>> 8, e[s + 2] = 255 ^ e[s], e[s + 3] = 255 ^ e[s + 1];
    for (var r = 0; r < n; ++r) e[s + r + 4] = i[r];
    return 8 * (s + 4 + n);
  },
  Mn = function (e, t, i, n, s, r, o, a, l, u, c) {
    Cn(t, c++, i), ++s[256];
    for (var d = Rn(s, 15), h = d[0], _ = d[1], p = Rn(r, 15), v = p[0], g = p[1], f = Tn(h), m = f[0], b = f[1], y = Tn(v), w = y[0], S = y[1], E = new an(19), k = 0; k < m.length; ++k) E[31 & m[k]]++;
    for (k = 0; k < w.length; ++k) E[31 & w[k]]++;
    for (var x = Rn(E, 7), I = x[0], C = x[1], P = 19; P > 4 && !I[dn[P - 1]]; --P);
    var R,
      F,
      T,
      $,
      O = u + 5 << 3,
      M = $n(s, wn) + $n(r, Sn) + o,
      A = $n(s, h) + $n(r, v) + o + 14 + 3 * P + $n(E, I) + (2 * E[16] + 3 * E[17] + 7 * E[18]);
    if (O <= M && O <= A) return On(t, c, e.subarray(l, l + u));
    if (Cn(t, c, 1 + (A < M)), c += 2, A < M) {
      R = yn(h, _, 0), F = h, T = yn(v, g, 0), $ = v;
      var L = yn(I, C, 0);
      Cn(t, c, b - 257), Cn(t, c + 5, S - 1), Cn(t, c + 10, P - 4), c += 14;
      for (k = 0; k < P; ++k) Cn(t, c + 3 * k, I[dn[k]]);
      c += 3 * P;
      for (var D = [m, w], N = 0; N < 2; ++N) {
        var q = D[N];
        for (k = 0; k < q.length; ++k) {
          var B = 31 & q[k];
          Cn(t, c, L[B]), c += I[B], B > 15 && (Cn(t, c, q[k] >>> 5 & 127), c += q[k] >>> 12);
        }
      }
    } else R = En, F = wn, T = kn, $ = Sn;
    for (k = 0; k < a; ++k) if (n[k] > 255) {
      B = n[k] >>> 18 & 31;
      Pn(t, c, R[B + 257]), c += F[B + 257], B > 7 && (Cn(t, c, n[k] >>> 23 & 31), c += un[B]);
      var H = 31 & n[k];
      Pn(t, c, T[H]), c += $[H], H > 3 && (Pn(t, c, n[k] >>> 5 & 8191), c += cn[H]);
    } else Pn(t, c, R[n[k]]), c += F[n[k]];
    return Pn(t, c, R[256]), c + F[256];
  },
  An = new ln([65540, 131080, 131088, 131104, 262176, 1048704, 1048832, 2114560, 2117632]),
  Ln = function () {
    for (var e = new ln(256), t = 0; t < 256; ++t) {
      for (var i = t, n = 9; --n;) i = (1 & i && 3988292384) ^ i >>> 1;
      e[t] = i;
    }
    return e;
  }(),
  Dn = function () {
    var e = 4294967295;
    return {
      p: function (t) {
        for (var i = e, n = 0; n < t.length; ++n) i = Ln[255 & i ^ t[n]] ^ i >>> 8;
        e = i;
      },
      d: function () {
        return 4294967295 ^ e;
      }
    };
  },
  Nn = function (e, t, i, n, s) {
    return function (e, t, i, n, s, r) {
      var o = e.length,
        a = new on(n + o + 5 * (1 + Math.floor(o / 7e3)) + s),
        l = a.subarray(n, a.length - s),
        u = 0;
      if (!t || o < 8) for (var c = 0; c <= o; c += 65535) {
        var d = c + 65535;
        d < o ? u = On(l, u, e.subarray(c, d)) : (l[c] = r, u = On(l, u, e.subarray(c, o)));
      } else {
        for (var h = An[t - 1], _ = h >>> 13, p = 8191 & h, v = (1 << i) - 1, g = new an(32768), f = new an(v + 1), m = Math.ceil(i / 3), b = 2 * m, y = function (t) {
            return (e[t] ^ e[t + 1] << m ^ e[t + 2] << b) & v;
          }, w = new ln(25e3), S = new an(288), E = new an(32), k = 0, x = 0, I = (c = 0, 0), C = 0, P = 0; c < o; ++c) {
          var R = y(c),
            F = 32767 & c,
            T = f[R];
          if (g[F] = T, f[R] = F, C <= c) {
            var $ = o - c;
            if ((k > 7e3 || I > 24576) && $ > 423) {
              u = Mn(e, l, 0, w, S, E, x, I, P, c - P, u), I = k = x = 0, P = c;
              for (var O = 0; O < 286; ++O) S[O] = 0;
              for (O = 0; O < 30; ++O) E[O] = 0;
            }
            var M = 2,
              A = 0,
              L = p,
              D = F - T & 32767;
            if ($ > 2 && R == y(c - D)) for (var N = Math.min(_, $) - 1, q = Math.min(32767, c), B = Math.min(258, $); D <= q && --L && F != T;) {
              if (e[c + M] == e[c + M - D]) {
                for (var H = 0; H < B && e[c + H] == e[c + H - D]; ++H);
                if (H > M) {
                  if (M = H, A = D, H > N) break;
                  var U = Math.min(D, H - 2),
                    z = 0;
                  for (O = 0; O < U; ++O) {
                    var W = c - D + O + 32768 & 32767,
                      j = W - g[W] + 32768 & 32767;
                    j > z && (z = j, T = W);
                  }
                }
              }
              D += (F = T) - (T = g[F]) + 32768 & 32767;
            }
            if (A) {
              w[I++] = 268435456 | vn[M] << 18 | gn[A];
              var G = 31 & vn[M],
                V = 31 & gn[A];
              x += un[G] + cn[V], ++S[257 + G], ++E[V], C = c + M, ++k;
            } else w[I++] = e[c], ++S[e[c]];
          }
        }
        u = Mn(e, l, r, w, S, E, x, I, P, c - P, u);
      }
      return In(a, 0, n + xn(u) + s);
    }(e, null == t.level ? 6 : t.level, null == t.mem ? Math.ceil(1.5 * Math.max(8, Math.min(13, Math.log(e.length)))) : 12 + t.mem, i, n, !s);
  },
  qn = function (e, t, i) {
    for (; i; ++t) e[t] = i, i >>>= 8;
  },
  Bn = function (e, t) {
    var i = t.filename;
    if (e[0] = 31, e[1] = 139, e[2] = 8, e[8] = t.level < 2 ? 4 : 9 == t.level ? 2 : 0, e[9] = 3, 0 != t.mtime && qn(e, 4, Math.floor(new Date(t.mtime || Date.now()) / 1e3)), i) {
      e[3] = 8;
      for (var n = 0; n <= i.length; ++n) e[n + 10] = i.charCodeAt(n);
    }
  },
  Hn = function (e) {
    return 10 + (e.filename && e.filename.length + 1 || 0);
  };
function Un(e, t) {
  void 0 === t && (t = {});
  var i = Dn(),
    n = e.length;
  i.p(e);
  var s = Nn(e, t, Hn(t), 8),
    r = s.length;
  return Bn(s, t), qn(s, r - 8, i.d()), qn(s, r - 4, n), s;
}
function zn(e, t) {
  var i = e.length;
  if ("undefined" != typeof TextEncoder) return new TextEncoder().encode(e);
  for (var n = new on(e.length + (e.length >>> 1)), s = 0, r = function (e) {
      n[s++] = e;
    }, o = 0; o < i; ++o) {
    if (s + 5 > n.length) {
      var a = new on(s + 8 + (i - o << 1));
      a.set(n), n = a;
    }
    var l = e.charCodeAt(o);
    l < 128 || t ? r(l) : l < 2048 ? (r(192 | l >>> 6), r(128 | 63 & l)) : l > 55295 && l < 57344 ? (r(240 | (l = 65536 + (1047552 & l) | 1023 & e.charCodeAt(++o)) >>> 18), r(128 | l >>> 12 & 63), r(128 | l >>> 6 & 63), r(128 | 63 & l)) : (r(224 | l >>> 12), r(128 | l >>> 6 & 63), r(128 | 63 & l));
  }
  return In(n, 0, s);
}
var Wn = 3e5,
  jn = [bi.MouseMove, bi.MouseInteraction, bi.Scroll, bi.ViewportResize, bi.Input, bi.TouchMove, bi.MediaInteraction, bi.Drag],
  Gn = e => ({
    rrwebMethod: e,
    enqueuedAt: Date.now(),
    attempt: 1
  }),
  Vn = "[SessionRecording]";
function Jn(e) {
  return function (e, t) {
    for (var i = "", n = 0; n < e.length;) {
      var s = e[n++];
      s < 128 || t ? i += String.fromCharCode(s) : s < 224 ? i += String.fromCharCode((31 & s) << 6 | 63 & e[n++]) : s < 240 ? i += String.fromCharCode((15 & s) << 12 | (63 & e[n++]) << 6 | 63 & e[n++]) : (s = ((15 & s) << 18 | (63 & e[n++]) << 12 | (63 & e[n++]) << 6 | 63 & e[n++]) - 65536, i += String.fromCharCode(55296 | s >> 10, 56320 | 1023 & s));
    }
    return i;
  }(Un(zn(JSON.stringify(e))), !0);
}
function Qn(e) {
  return e.type === mi.Custom && "sessionIdle" === e.data.tag;
}
function Yn(e, t) {
  return t.some(t => "regex" === t.matching && new RegExp(t.url).test(e));
}
class Xn {
  get sessionIdleThresholdMilliseconds() {
    return this.instance.config.session_recording.session_idle_threshold_ms || 3e5;
  }
  get rrwebRecord() {
    var e, t;
    return null == m || null === (e = m.__PosthogExtensions__) || void 0 === e || null === (t = e.rrweb) || void 0 === t ? void 0 : t.record;
  }
  get started() {
    return this._captureStarted;
  }
  get sessionManager() {
    if (!this.instance.sessionManager) throw new Error(Vn + " must be started with a valid sessionManager.");
    return this.instance.sessionManager;
  }
  get fullSnapshotIntervalMillis() {
    var e, t;
    return "trigger_pending" === this.triggerStatus ? 6e4 : null !== (e = null === (t = this.instance.config.session_recording) || void 0 === t ? void 0 : t.full_snapshot_interval_millis) && void 0 !== e ? e : Wn;
  }
  get isSampled() {
    var e = this.instance.get_property(be);
    return L(e) ? e : null;
  }
  get sessionDuration() {
    var e,
      t,
      i = null === (e = this.buffer) || void 0 === e ? void 0 : e.data[(null === (t = this.buffer) || void 0 === t ? void 0 : t.data.length) - 1],
      {
        sessionStartTimestamp: n
      } = this.sessionManager.checkAndGetSessionAndWindowId(!0);
    return i ? i.timestamp - n : null;
  }
  get isRecordingEnabled() {
    var e = !!this.instance.get_property(de),
      t = !this.instance.config.disable_session_recording;
    return o && e && t;
  }
  get isConsoleLogCaptureEnabled() {
    var e = !!this.instance.get_property(he),
      t = this.instance.config.enable_recording_console_log;
    return null != t ? t : e;
  }
  get canvasRecording() {
    var e,
      t,
      i,
      n,
      s,
      r,
      o = this.instance.config.session_recording.captureCanvas,
      a = this.instance.get_property(pe),
      l = null !== (e = null !== (t = null == o ? void 0 : o.recordCanvas) && void 0 !== t ? t : null == a ? void 0 : a.enabled) && void 0 !== e && e,
      u = null !== (i = null !== (n = null == o ? void 0 : o.canvasFps) && void 0 !== n ? n : null == a ? void 0 : a.fps) && void 0 !== i ? i : 0,
      c = null !== (s = null !== (r = null == o ? void 0 : o.canvasQuality) && void 0 !== r ? r : null == a ? void 0 : a.quality) && void 0 !== s ? s : 0;
    return {
      enabled: l,
      fps: sn(u, 0, 12, "canvas recording fps"),
      quality: sn(c, 0, 1, "canvas recording quality")
    };
  }
  get networkPayloadCapture() {
    var e,
      t,
      i = this.instance.get_property(_e),
      n = {
        recordHeaders: null === (e = this.instance.config.session_recording) || void 0 === e ? void 0 : e.recordHeaders,
        recordBody: null === (t = this.instance.config.session_recording) || void 0 === t ? void 0 : t.recordBody
      },
      s = (null == n ? void 0 : n.recordHeaders) || (null == i ? void 0 : i.recordHeaders),
      r = (null == n ? void 0 : n.recordBody) || (null == i ? void 0 : i.recordBody),
      o = P(this.instance.config.capture_performance) ? this.instance.config.capture_performance.network_timing : this.instance.config.capture_performance,
      a = !!(L(o) ? o : null == i ? void 0 : i.capturePerformance);
    return s || r || a ? {
      recordHeaders: s,
      recordBody: r,
      recordPerformance: a
    } : void 0;
  }
  get sampleRate() {
    var e = this.instance.get_property(ve);
    return A(e) ? e : null;
  }
  get minimumDuration() {
    var e = this.instance.get_property(ge);
    return A(e) ? e : null;
  }
  get status() {
    return this.receivedDecide ? this.isRecordingEnabled ? this._urlBlocked ? "paused" : M(this._linkedFlag) || this._linkedFlagSeen ? "trigger_pending" === this.triggerStatus ? "buffering" : L(this.isSampled) ? this.isSampled ? "sampled" : "disabled" : "active" : "buffering" : "disabled" : "buffering";
  }
  get urlTriggerStatus() {
    var e;
    return 0 === this._urlTriggers.length ? "trigger_disabled" : (null === (e = this.instance) || void 0 === e ? void 0 : e.get_property(ye)) === this.sessionId ? "trigger_activated" : "trigger_pending";
  }
  get eventTriggerStatus() {
    var e;
    return 0 === this._eventTriggers.length ? "trigger_disabled" : (null === (e = this.instance) || void 0 === e ? void 0 : e.get_property(we)) === this.sessionId ? "trigger_activated" : "trigger_pending";
  }
  get triggerStatus() {
    var e = "trigger_activated" === this.eventTriggerStatus || "trigger_activated" === this.urlTriggerStatus,
      t = "trigger_pending" === this.eventTriggerStatus || "trigger_pending" === this.urlTriggerStatus;
    return e ? "trigger_activated" : t ? "trigger_pending" : "trigger_disabled";
  }
  constructor(e) {
    if (i(this, "queuedRRWebEvents", []), i(this, "isIdle", !1), i(this, "_linkedFlagSeen", !1), i(this, "_lastActivityTimestamp", Date.now()), i(this, "_linkedFlag", null), i(this, "_removePageViewCaptureHook", void 0), i(this, "_onSessionIdListener", void 0), i(this, "_persistDecideOnSessionListener", void 0), i(this, "_samplingSessionListener", void 0), i(this, "_urlTriggers", []), i(this, "_urlBlocklist", []), i(this, "_urlBlocked", !1), i(this, "_eventTriggers", []), i(this, "_removeEventTriggerCaptureHook", void 0), i(this, "_forceAllowLocalhostNetworkCapture", !1), i(this, "_onBeforeUnload", () => {
      this._flushBuffer();
    }), i(this, "_onOffline", () => {
      this._tryAddCustomEvent("browser offline", {});
    }), i(this, "_onOnline", () => {
      this._tryAddCustomEvent("browser online", {});
    }), i(this, "_onVisibilityChange", () => {
      if (null != h && h.visibilityState) {
        var e = "window " + h.visibilityState;
        this._tryAddCustomEvent(e, {});
      }
    }), this.instance = e, this._captureStarted = !1, this._endpoint = "/s/", this.stopRrweb = void 0, this.receivedDecide = !1, !this.instance.sessionManager) throw B.error(Vn + " started without valid sessionManager"), new Error(Vn + " started without valid sessionManager. This is a bug.");
    var {
      sessionId: t,
      windowId: n
    } = this.sessionManager.checkAndGetSessionAndWindowId();
    this.sessionId = t, this.windowId = n, this.buffer = this.clearBuffer(), this.sessionIdleThresholdMilliseconds >= this.sessionManager.sessionTimeoutMs && B.warn(Vn + " session_idle_threshold_ms (".concat(this.sessionIdleThresholdMilliseconds, ") is greater than the session timeout (").concat(this.sessionManager.sessionTimeoutMs, "). Session will never be detected as idle"));
  }
  startIfEnabledOrStop(e) {
    this.isRecordingEnabled ? (this._startCapture(e), null == o || o.addEventListener("beforeunload", this._onBeforeUnload), null == o || o.addEventListener("offline", this._onOffline), null == o || o.addEventListener("online", this._onOnline), null == o || o.addEventListener("visibilitychange", this._onVisibilityChange), this._setupSampling(), this._addEventTriggerListener(), M(this._removePageViewCaptureHook) && (this._removePageViewCaptureHook = this.instance.on("eventCaptured", e => {
      try {
        if ("$pageview" === e.event) {
          var t = null != e && e.properties.$current_url ? this._maskUrl(null == e ? void 0 : e.properties.$current_url) : "";
          if (!t) return;
          this._tryAddCustomEvent("$pageview", {
            href: t
          });
        }
      } catch (e) {
        B.error("Could not add $pageview to rrweb session", e);
      }
    })), this._onSessionIdListener || (this._onSessionIdListener = this.sessionManager.onSessionId((e, t, i) => {
      var n, s, r, o;
      i && (this._tryAddCustomEvent("$session_id_change", {
        sessionId: e,
        windowId: t,
        changeReason: i
      }), null === (n = this.instance) || void 0 === n || null === (s = n.persistence) || void 0 === s || s.unregister(we), null === (r = this.instance) || void 0 === r || null === (o = r.persistence) || void 0 === o || o.unregister(ye));
    }))) : this.stopRecording();
  }
  stopRecording() {
    var e, t, i, n;
    this._captureStarted && this.stopRrweb && (this.stopRrweb(), this.stopRrweb = void 0, this._captureStarted = !1, null == o || o.removeEventListener("beforeunload", this._onBeforeUnload), null == o || o.removeEventListener("offline", this._onOffline), null == o || o.removeEventListener("online", this._onOnline), null == o || o.removeEventListener("visibilitychange", this._onVisibilityChange), this.clearBuffer(), clearInterval(this._fullSnapshotTimer), null === (e = this._removePageViewCaptureHook) || void 0 === e || e.call(this), this._removePageViewCaptureHook = void 0, null === (t = this._removeEventTriggerCaptureHook) || void 0 === t || t.call(this), this._removeEventTriggerCaptureHook = void 0, null === (i = this._onSessionIdListener) || void 0 === i || i.call(this), this._onSessionIdListener = void 0, null === (n = this._samplingSessionListener) || void 0 === n || n.call(this), this._samplingSessionListener = void 0, B.info(Vn + " stopped"));
  }
  makeSamplingDecision(e) {
    var t,
      i = this.sessionId !== e,
      n = this.sampleRate;
    if (A(n)) {
      var s,
        r = this.isSampled,
        o = i || !L(r);
      if (o) s = Math.random() < n;else s = r;
      o && (s ? this._reportStarted("sampled") : B.warn(Vn + " Sample rate (".concat(n, ") has determined that this sessionId (").concat(e, ") will not be sent to the server.")), this._tryAddCustomEvent("samplingDecisionMade", {
        sampleRate: n,
        isSampled: s
      })), null === (t = this.instance.persistence) || void 0 === t || t.register({
        [be]: s
      });
    } else {
      var a;
      null === (a = this.instance.persistence) || void 0 === a || a.register({
        [be]: null
      });
    }
  }
  onRemoteConfig(e) {
    var t, i, n, s, r, o;
    (this._persistRemoteConfig(e), this._linkedFlag = (null === (t = e.sessionRecording) || void 0 === t ? void 0 : t.linkedFlag) || null, null !== (i = e.sessionRecording) && void 0 !== i && i.endpoint) && (this._endpoint = null === (o = e.sessionRecording) || void 0 === o ? void 0 : o.endpoint);
    if (this._setupSampling(), !M(this._linkedFlag) && !this._linkedFlagSeen) {
      var a = T(this._linkedFlag) ? this._linkedFlag : this._linkedFlag.flag,
        l = T(this._linkedFlag) ? null : this._linkedFlag.variant;
      this.instance.onFeatureFlags((e, t) => {
        var i = P(t) && a in t,
          n = l ? t[a] === l : i;
        n && this._reportStarted("linked_flag_matched", {
          linkedFlag: a,
          linkedVariant: l
        }), this._linkedFlagSeen = n;
      });
    }
    null !== (n = e.sessionRecording) && void 0 !== n && n.urlTriggers && (this._urlTriggers = e.sessionRecording.urlTriggers), null !== (s = e.sessionRecording) && void 0 !== s && s.urlBlocklist && (this._urlBlocklist = e.sessionRecording.urlBlocklist), null !== (r = e.sessionRecording) && void 0 !== r && r.eventTriggers && (this._eventTriggers = e.sessionRecording.eventTriggers), this.receivedDecide = !0, this.startIfEnabledOrStop();
  }
  _setupSampling() {
    A(this.sampleRate) && M(this._samplingSessionListener) && (this._samplingSessionListener = this.sessionManager.onSessionId(e => {
      this.makeSamplingDecision(e);
    }));
  }
  _persistRemoteConfig(e) {
    if (this.instance.persistence) {
      var i,
        n = this.instance.persistence,
        s = () => {
          var i,
            s,
            r,
            o,
            a,
            l,
            u,
            c,
            d = null === (i = e.sessionRecording) || void 0 === i ? void 0 : i.sampleRate,
            h = M(d) ? null : parseFloat(d),
            _ = null === (s = e.sessionRecording) || void 0 === s ? void 0 : s.minimumDurationMilliseconds;
          n.register({
            [de]: !!e.sessionRecording,
            [he]: null === (r = e.sessionRecording) || void 0 === r ? void 0 : r.consoleLogRecordingEnabled,
            [_e]: t({
              capturePerformance: e.capturePerformance
            }, null === (o = e.sessionRecording) || void 0 === o ? void 0 : o.networkPayloadCapture),
            [pe]: {
              enabled: null === (a = e.sessionRecording) || void 0 === a ? void 0 : a.recordCanvas,
              fps: null === (l = e.sessionRecording) || void 0 === l ? void 0 : l.canvasFps,
              quality: null === (u = e.sessionRecording) || void 0 === u ? void 0 : u.canvasQuality
            },
            [ve]: h,
            [ge]: F(_) ? null : _,
            [fe]: null === (c = e.sessionRecording) || void 0 === c ? void 0 : c.scriptConfig
          });
        };
      s(), null === (i = this._persistDecideOnSessionListener) || void 0 === i || i.call(this), this._persistDecideOnSessionListener = this.sessionManager.onSessionId(s);
    }
  }
  log(e) {
    var t,
      i = arguments.length > 1 && void 0 !== arguments[1] ? arguments[1] : "log";
    null === (t = this.instance.sessionRecording) || void 0 === t || t.onRRwebEmit({
      type: 6,
      data: {
        plugin: "rrweb/console@1",
        payload: {
          level: i,
          trace: [],
          payload: [JSON.stringify(e)]
        }
      },
      timestamp: Date.now()
    });
  }
  _startCapture(e) {
    if (!F(Object.assign) && !F(Array.from) && !(this._captureStarted || this.instance.config.disable_session_recording || this.instance.consent.isOptedOut())) {
      var t, i;
      if (this._captureStarted = !0, this.sessionManager.checkAndGetSessionAndWindowId(), this.rrwebRecord) this._onScriptLoaded();else null === (t = m.__PosthogExtensions__) || void 0 === t || null === (i = t.loadExternalDependency) || void 0 === i || i.call(t, this.instance, this.scriptName, e => {
        if (e) return B.error(Vn + " could not load recorder", e);
        this._onScriptLoaded();
      });
      B.info(Vn + " starting"), "active" === this.status && this._reportStarted(e || "recording_initialized");
    }
  }
  get scriptName() {
    var e, t, i;
    return (null === (e = this.instance) || void 0 === e || null === (t = e.persistence) || void 0 === t || null === (i = t.get_property(fe)) || void 0 === i ? void 0 : i.script) || "recorder";
  }
  isInteractiveEvent(e) {
    var t;
    return 3 === e.type && -1 !== jn.indexOf(null === (t = e.data) || void 0 === t ? void 0 : t.source);
  }
  _updateWindowAndSessionIds(e) {
    var t = this.isInteractiveEvent(e);
    t || this.isIdle || e.timestamp - this._lastActivityTimestamp > this.sessionIdleThresholdMilliseconds && (this.isIdle = !0, clearInterval(this._fullSnapshotTimer), this._tryAddCustomEvent("sessionIdle", {
      eventTimestamp: e.timestamp,
      lastActivityTimestamp: this._lastActivityTimestamp,
      threshold: this.sessionIdleThresholdMilliseconds,
      bufferLength: this.buffer.data.length,
      bufferSize: this.buffer.size
    }), this._flushBuffer());
    var i = !1;
    if (t && (this._lastActivityTimestamp = e.timestamp, this.isIdle && (this.isIdle = !1, this._tryAddCustomEvent("sessionNoLongerIdle", {
      reason: "user activity",
      type: e.type
    }), i = !0)), !this.isIdle) {
      var {
          windowId: n,
          sessionId: s
        } = this.sessionManager.checkAndGetSessionAndWindowId(!t, e.timestamp),
        r = this.sessionId !== s,
        o = this.windowId !== n;
      this.windowId = n, this.sessionId = s, r || o ? (this.stopRecording(), this.startIfEnabledOrStop("session_id_changed")) : i && this._scheduleFullSnapshot();
    }
  }
  _tryRRWebMethod(e) {
    try {
      return e.rrwebMethod(), !0;
    } catch (t) {
      return this.queuedRRWebEvents.length < 10 ? this.queuedRRWebEvents.push({
        enqueuedAt: e.enqueuedAt || Date.now(),
        attempt: e.attempt++,
        rrwebMethod: e.rrwebMethod
      }) : B.warn(Vn + " could not emit queued rrweb event.", t, e), !1;
    }
  }
  _tryAddCustomEvent(e, t) {
    return this._tryRRWebMethod(Gn(() => this.rrwebRecord.addCustomEvent(e, t)));
  }
  _tryTakeFullSnapshot() {
    return this._tryRRWebMethod(Gn(() => this.rrwebRecord.takeFullSnapshot()));
  }
  _onScriptLoaded() {
    var e,
      i = {
        blockClass: "ph-no-capture",
        blockSelector: void 0,
        ignoreClass: "ph-ignore-input",
        maskTextClass: "ph-mask",
        maskTextSelector: void 0,
        maskTextFn: void 0,
        maskAllInputs: !0,
        maskInputOptions: {
          password: !0
        },
        maskInputFn: void 0,
        slimDOMOptions: {},
        collectFonts: !1,
        inlineStylesheet: !0,
        recordCrossOriginIframes: !1
      },
      n = this.instance.config.session_recording;
    for (var [s, r] of Object.entries(n || {})) s in i && ("maskInputOptions" === s ? i.maskInputOptions = t({
      password: !0
    }, r) : i[s] = r);
    if (this.canvasRecording && this.canvasRecording.enabled && (i.recordCanvas = !0, i.sampling = {
      canvas: this.canvasRecording.fps
    }, i.dataURLOptions = {
      type: "image/webp",
      quality: this.canvasRecording.quality
    }), this.rrwebRecord) {
      this.mutationRateLimiter = null !== (e = this.mutationRateLimiter) && void 0 !== e ? e : new rn(this.rrwebRecord, {
        refillRate: this.instance.config.session_recording.__mutationRateLimiterRefillRate,
        bucketSize: this.instance.config.session_recording.__mutationRateLimiterBucketSize,
        onBlockedNode: (e, t) => {
          var i = "Too many mutations on node '".concat(e, "'. Rate limiting. This could be due to SVG animations or something similar");
          B.info(i, {
            node: t
          }), this.log(Vn + " " + i, "warn");
        }
      });
      var o = this._gatherRRWebPlugins();
      this.stopRrweb = this.rrwebRecord(t({
        emit: e => {
          this.onRRwebEmit(e);
        },
        plugins: o
      }, i)), this._lastActivityTimestamp = Date.now(), this.isIdle = !1, this._tryAddCustomEvent("$session_options", {
        sessionRecordingOptions: i,
        activePlugins: o.map(e => null == e ? void 0 : e.name)
      }), this._tryAddCustomEvent("$posthog_config", {
        config: this.instance.config
      });
    } else B.error(Vn + "onScriptLoaded was called but rrwebRecord is not available. This indicates something has gone wrong.");
  }
  _scheduleFullSnapshot() {
    if (this._fullSnapshotTimer && clearInterval(this._fullSnapshotTimer), !this.isIdle) {
      var e = this.fullSnapshotIntervalMillis;
      e && (this._fullSnapshotTimer = setInterval(() => {
        this._tryTakeFullSnapshot();
      }, e));
    }
  }
  _gatherRRWebPlugins() {
    var e,
      t,
      i,
      n,
      s = [],
      r = null === (e = m.__PosthogExtensions__) || void 0 === e || null === (t = e.rrwebPlugins) || void 0 === t ? void 0 : t.getRecordConsolePlugin;
    r && this.isConsoleLogCaptureEnabled && s.push(r());
    var o = null === (i = m.__PosthogExtensions__) || void 0 === i || null === (n = i.rrwebPlugins) || void 0 === n ? void 0 : n.getRecordNetworkPlugin;
    this.networkPayloadCapture && C(o) && (!ct.includes(location.hostname) || this._forceAllowLocalhostNetworkCapture ? s.push(o(nn(this.instance.config, this.networkPayloadCapture))) : B.info(Vn + " NetworkCapture not started because we are on localhost."));
    return s;
  }
  onRRwebEmit(e) {
    var i;
    if (this._processQueuedEvents(), e && P(e)) {
      if (e.type === mi.Meta) {
        var n = this._maskUrl(e.data.href);
        if (this._lastHref = n, !n) return;
        e.data.href = n;
      } else this._pageViewFallBack();
      if (this._checkUrlTriggerConditions(), "paused" !== this.status || function (e) {
        return e.type === mi.Custom && "recording paused" === e.data.tag;
      }(e)) {
        e.type === mi.FullSnapshot && this._scheduleFullSnapshot(), e.type === mi.FullSnapshot && "trigger_pending" === this.triggerStatus && this.clearBuffer();
        var s = this.mutationRateLimiter ? this.mutationRateLimiter.throttleMutations(e) : e;
        if (s) {
          var r = function (e) {
            var t = e;
            if (t && P(t) && 6 === t.type && P(t.data) && "rrweb/console@1" === t.data.plugin) {
              t.data.payload.payload.length > 10 && (t.data.payload.payload = t.data.payload.payload.slice(0, 10), t.data.payload.payload.push("...[truncated]"));
              for (var i = [], n = 0; n < t.data.payload.payload.length; n++) t.data.payload.payload[n] && t.data.payload.payload[n].length > 2e3 ? i.push(t.data.payload.payload[n].slice(0, 2e3) + "...[truncated]") : i.push(t.data.payload.payload[n]);
              return t.data.payload.payload = i, e;
            }
            return e;
          }(s);
          if (this._updateWindowAndSessionIds(r), !this.isIdle || Qn(r)) {
            if (Qn(r)) {
              var o = r.data.payload;
              if (o) {
                var a = o.lastActivityTimestamp,
                  l = o.threshold;
                r.timestamp = a + l;
              }
            }
            var u = null === (i = this.instance.config.session_recording.compress_events) || void 0 === i || i ? function (e) {
                if (gi(e) < 1024) return e;
                try {
                  if (e.type === mi.FullSnapshot) return t(t({}, e), {}, {
                    data: Jn(e.data),
                    cv: "2024-10"
                  });
                  if (e.type === mi.IncrementalSnapshot && e.data.source === bi.Mutation) return t(t({}, e), {}, {
                    cv: "2024-10",
                    data: t(t({}, e.data), {}, {
                      texts: Jn(e.data.texts),
                      attributes: Jn(e.data.attributes),
                      removes: Jn(e.data.removes),
                      adds: Jn(e.data.adds)
                    })
                  });
                  if (e.type === mi.IncrementalSnapshot && e.data.source === bi.StyleSheetRule) return t(t({}, e), {}, {
                    cv: "2024-10",
                    data: t(t({}, e.data), {}, {
                      adds: Jn(e.data.adds),
                      removes: Jn(e.data.removes)
                    })
                  });
                } catch (e) {
                  B.error(Vn + " could not compress event - will use uncompressed event", e);
                }
                return e;
              }(r) : r,
              c = {
                $snapshot_bytes: gi(u),
                $snapshot_data: u,
                $session_id: this.sessionId,
                $window_id: this.windowId
              };
            "disabled" !== this.status ? this._captureSnapshotBuffered(c) : this.clearBuffer();
          }
        }
      }
    }
  }
  _pageViewFallBack() {
    if (!this.instance.config.capture_pageview && o) {
      var e = this._maskUrl(o.location.href);
      this._lastHref !== e && (this._tryAddCustomEvent("$url_changed", {
        href: e
      }), this._lastHref = e);
    }
  }
  _processQueuedEvents() {
    if (this.queuedRRWebEvents.length) {
      var e = [...this.queuedRRWebEvents];
      this.queuedRRWebEvents = [], e.forEach(e => {
        Date.now() - e.enqueuedAt <= 2e3 && this._tryRRWebMethod(e);
      });
    }
  }
  _maskUrl(e) {
    var t = this.instance.config.session_recording;
    if (t.maskNetworkRequestFn) {
      var i,
        n = {
          url: e
        };
      return null === (i = n = t.maskNetworkRequestFn(n)) || void 0 === i ? void 0 : i.url;
    }
    return e;
  }
  clearBuffer() {
    return this.buffer = {
      size: 0,
      data: [],
      sessionId: this.sessionId,
      windowId: this.windowId
    }, this.buffer;
  }
  _flushBuffer() {
    this.flushBufferTimer && (clearTimeout(this.flushBufferTimer), this.flushBufferTimer = void 0);
    var e = this.minimumDuration,
      t = this.sessionDuration,
      i = A(t) && t >= 0,
      n = A(e) && i && t < e;
    if ("buffering" === this.status || n) return this.flushBufferTimer = setTimeout(() => {
      this._flushBuffer();
    }, 2e3), this.buffer;
    this.buffer.data.length > 0 && fi(this.buffer).forEach(e => {
      this._captureSnapshot({
        $snapshot_bytes: e.size,
        $snapshot_data: e.data,
        $session_id: e.sessionId,
        $window_id: e.windowId
      });
    });
    return this.clearBuffer();
  }
  _captureSnapshotBuffered(e) {
    var t,
      i = 2 + ((null === (t = this.buffer) || void 0 === t ? void 0 : t.data.length) || 0);
    !this.isIdle && (this.buffer.size + e.$snapshot_bytes + i > 943718.4 || this.buffer.sessionId !== this.sessionId) && (this.buffer = this._flushBuffer()), this.buffer.size += e.$snapshot_bytes, this.buffer.data.push(e.$snapshot_data), this.flushBufferTimer || this.isIdle || (this.flushBufferTimer = setTimeout(() => {
      this._flushBuffer();
    }, 2e3));
  }
  _captureSnapshot(e) {
    this.instance.capture("$snapshot", e, {
      _url: this.instance.requestRouter.endpointFor("api", this._endpoint),
      _noTruncate: !0,
      _batchKey: "recordings",
      skip_client_rate_limiting: !0
    });
  }
  _checkUrlTriggerConditions() {
    if (void 0 !== o && o.location.href) {
      var e = o.location.href,
        t = "paused" === this.status,
        i = Yn(e, this._urlBlocklist);
      i && !t ? this._pauseRecording() : !i && t && this._resumeRecording(), Yn(e, this._urlTriggers) && this._activateTrigger("url");
    }
  }
  _activateTrigger(e) {
    var t, i;
    "trigger_pending" === this.triggerStatus && (null === (t = this.instance) || void 0 === t || null === (i = t.persistence) || void 0 === i || i.register({
      ["url" === e ? ye : we]: this.sessionId
    }), this._flushBuffer(), this._reportStarted(e + "_trigger_matched"));
  }
  _pauseRecording() {
    var e, t;
    "paused" !== this.status && (this._urlBlocked = !0, null == h || null === (e = h.body) || void 0 === e || null === (t = e.classList) || void 0 === t || t.add("ph-no-capture"), clearInterval(this._fullSnapshotTimer), setTimeout(() => {
      this._flushBuffer();
    }, 100), B.info(Vn + " recording paused due to URL blocker"), this._tryAddCustomEvent("recording paused", {
      reason: "url blocker"
    }));
  }
  _resumeRecording() {
    var e, t;
    "paused" === this.status && (this._urlBlocked = !1, null == h || null === (e = h.body) || void 0 === e || null === (t = e.classList) || void 0 === t || t.remove("ph-no-capture"), this._tryTakeFullSnapshot(), this._scheduleFullSnapshot(), this._tryAddCustomEvent("recording resumed", {
      reason: "left blocked url"
    }), B.info(Vn + " recording resumed"));
  }
  _addEventTriggerListener() {
    0 !== this._eventTriggers.length && M(this._removeEventTriggerCaptureHook) && (this._removeEventTriggerCaptureHook = this.instance.on("eventCaptured", e => {
      try {
        this._eventTriggers.includes(e.event) && this._activateTrigger("event");
      } catch (e) {
        B.error(Vn + "Could not activate event trigger", e);
      }
    }));
  }
  overrideLinkedFlag() {
    this._linkedFlagSeen = !0, this._reportStarted("linked_flag_overridden");
  }
  overrideSampling() {
    var e;
    null === (e = this.instance.persistence) || void 0 === e || e.register({
      [be]: !0
    }), this._reportStarted("sampling_overridden");
  }
  overrideTrigger(e) {
    this._activateTrigger(e);
  }
  _reportStarted(e, t) {
    this.instance.register_for_session({
      $session_recording_start_reason: e
    }), B.info(Vn + " " + e.replace("_", " "), t), G(["recording_initialized", "session_id_changed"], e) || this._tryAddCustomEvent(e, t);
  }
}
class Kn {
  constructor(e) {
    this.instance = e, this.instance.decideEndpointWasHit = this.instance._hasBootstrappedFeatureFlags();
  }
  _loadRemoteConfigJs(e) {
    var t, i, n;
    null !== (t = m.__PosthogExtensions__) && void 0 !== t && t.loadExternalDependency ? null === (i = m.__PosthogExtensions__) || void 0 === i || null === (n = i.loadExternalDependency) || void 0 === n || n.call(i, this.instance, "remote-config", () => e(m._POSTHOG_CONFIG)) : (B.error("PostHog Extensions not found. Cannot load remote config."), e());
  }
  _loadRemoteConfigJSON(e) {
    this.instance._send_request({
      method: "GET",
      url: this.instance.requestRouter.endpointFor("assets", "/array/".concat(this.instance.config.token, "/config")),
      callback: t => {
        e(t.json);
      }
    });
  }
  call() {
    var e = !!this.instance.config.advanced_disable_decide;
    if (e || this.instance.featureFlags.resetRequestQueue(), this.instance.config.__preview_remote_config) return m._POSTHOG_CONFIG ? (B.info("Using preloaded remote config", m._POSTHOG_CONFIG), void this.onRemoteConfig(m._POSTHOG_CONFIG)) : e ? void B.warn("Remote config is disabled. Falling back to local config.") : void this._loadRemoteConfigJs(e => {
      if (!e) return B.info("No config found after loading remote JS config. Falling back to JSON."), void this._loadRemoteConfigJSON(e => {
        this.onRemoteConfig(e);
      });
      this.onRemoteConfig(e);
    });
    if (!e) {
      var t = {
        token: this.instance.config.token,
        distinct_id: this.instance.get_distinct_id(),
        groups: this.instance.getGroups(),
        person_properties: this.instance.get_property(ke),
        group_properties: this.instance.get_property(xe),
        disable_flags: this.instance.config.advanced_disable_feature_flags || this.instance.config.advanced_disable_feature_flags_on_first_load || void 0
      };
      this.instance._send_request({
        method: "POST",
        url: this.instance.requestRouter.endpointFor("api", "/decide/?v=3"),
        data: t,
        compression: this.instance.config.disable_compression ? void 0 : s.Base64,
        timeout: this.instance.config.feature_flag_request_timeout_ms,
        callback: e => this.parseDecideResponse(e.json)
      });
    }
  }
  parseDecideResponse(e) {
    this.instance.featureFlags.setReloadingPaused(!1), this.instance.featureFlags._startReloadTimer();
    var t = !e;
    if (this.instance.config.advanced_disable_feature_flags_on_first_load || this.instance.config.advanced_disable_feature_flags || this.instance.featureFlags.receivedFeatureFlags(null != e ? e : {}, t), !t) return h && h.body ? void this.instance._onRemoteConfig(e) : (B.info("document not ready yet, trying again in 500 milliseconds..."), void setTimeout(() => {
      this.parseDecideResponse(e);
    }, 500));
    B.error("Failed to fetch feature flags from PostHog.");
  }
  onRemoteConfig(e) {
    if (e) {
      if (!h || !h.body) return B.info("document not ready yet, trying again in 500 milliseconds..."), void setTimeout(() => {
        this.onRemoteConfig(e);
      }, 500);
      this.instance._onRemoteConfig(e), !1 !== e.hasFeatureFlags && (this.instance.featureFlags.setReloadingPaused(!1), this.instance.featureFlags.reloadFeatureFlags());
    } else B.error("Failed to fetch remote config from PostHog.");
  }
}
var Zn,
  es = null != o && o.location ? vt(o.location.hash, "__posthog") || vt(location.hash, "state") : null,
  ts = "_postHogToolbarParams";
!function (e) {
  e[e.UNINITIALIZED = 0] = "UNINITIALIZED", e[e.LOADING = 1] = "LOADING", e[e.LOADED = 2] = "LOADED";
}(Zn || (Zn = {}));
class is {
  constructor(e) {
    this.instance = e;
  }
  setToolbarState(e) {
    m.ph_toolbar_state = e;
  }
  getToolbarState() {
    var e;
    return null !== (e = m.ph_toolbar_state) && void 0 !== e ? e : Zn.UNINITIALIZED;
  }
  maybeLoadToolbar() {
    var e,
      t,
      i = arguments.length > 0 && void 0 !== arguments[0] ? arguments[0] : void 0,
      n = arguments.length > 1 && void 0 !== arguments[1] ? arguments[1] : void 0,
      s = arguments.length > 2 && void 0 !== arguments[2] ? arguments[2] : void 0;
    if (!o || !h) return !1;
    i = null !== (e = i) && void 0 !== e ? e : o.location, s = null !== (t = s) && void 0 !== t ? t : o.history;
    try {
      if (!n) {
        try {
          o.localStorage.setItem("test", "test"), o.localStorage.removeItem("test");
        } catch (e) {
          return !1;
        }
        n = null == o ? void 0 : o.localStorage;
      }
      var r,
        a = es || vt(i.hash, "__posthog") || vt(i.hash, "state"),
        l = a ? J(() => JSON.parse(atob(decodeURIComponent(a)))) || J(() => JSON.parse(decodeURIComponent(a))) : null;
      return l && "ph_authorize" === l.action ? ((r = l).source = "url", r && Object.keys(r).length > 0 && (l.desiredHash ? i.hash = l.desiredHash : s ? s.replaceState(s.state, "", i.pathname + i.search) : i.hash = "")) : ((r = JSON.parse(n.getItem(ts) || "{}")).source = "localstorage", delete r.userIntent), !(!r.token || this.instance.config.token !== r.token) && (this.loadToolbar(r), !0);
    } catch (e) {
      return !1;
    }
  }
  _callLoadToolbar(e) {
    (m.ph_load_toolbar || m.ph_load_editor)(e, this.instance);
  }
  loadToolbar(e) {
    var i = !(null == h || !h.getElementById(Le));
    if (!o || i) return !1;
    var n = "custom" === this.instance.requestRouter.region && this.instance.config.advanced_disable_toolbar_metrics,
      s = t(t({
        token: this.instance.config.token
      }, e), {}, {
        apiURL: this.instance.requestRouter.endpointFor("ui")
      }, n ? {
        instrument: !1
      } : {});
    if (o.localStorage.setItem(ts, JSON.stringify(t(t({}, s), {}, {
      source: void 0
    }))), this.getToolbarState() === Zn.LOADED) this._callLoadToolbar(s);else if (this.getToolbarState() === Zn.UNINITIALIZED) {
      var r, a;
      this.setToolbarState(Zn.LOADING), null === (r = m.__PosthogExtensions__) || void 0 === r || null === (a = r.loadExternalDependency) || void 0 === a || a.call(r, this.instance, "toolbar", e => {
        if (e) return B.error("Failed to load toolbar", e), void this.setToolbarState(Zn.UNINITIALIZED);
        this.setToolbarState(Zn.LOADED), this._callLoadToolbar(s);
      }), ee(o, "turbolinks:load", () => {
        this.setToolbarState(Zn.UNINITIALIZED), this.loadToolbar(s);
      });
    }
    return !0;
  }
  _loadEditor(e) {
    return this.loadToolbar(e);
  }
  maybeLoadEditor() {
    var e = arguments.length > 0 && void 0 !== arguments[0] ? arguments[0] : void 0,
      t = arguments.length > 1 && void 0 !== arguments[1] ? arguments[1] : void 0,
      i = arguments.length > 2 && void 0 !== arguments[2] ? arguments[2] : void 0;
    return this.maybeLoadToolbar(e, t, i);
  }
}
class ns {
  constructor(e) {
    i(this, "isPaused", !0), i(this, "queue", []), i(this, "flushTimeoutMs", 3e3), this.sendRequest = e;
  }
  enqueue(e) {
    this.queue.push(e), this.flushTimeout || this.setFlushTimeout();
  }
  unload() {
    this.clearFlushTimeout();
    var e = this.queue.length > 0 ? this.formatQueue() : {},
      i = Object.values(e),
      n = [...i.filter(e => 0 === e.url.indexOf("/e")), ...i.filter(e => 0 !== e.url.indexOf("/e"))];
    n.map(e => {
      this.sendRequest(t(t({}, e), {}, {
        transport: "sendBeacon"
      }));
    });
  }
  enable() {
    this.isPaused = !1, this.setFlushTimeout();
  }
  setFlushTimeout() {
    var e = this;
    this.isPaused || (this.flushTimeout = setTimeout(() => {
      if (this.clearFlushTimeout(), this.queue.length > 0) {
        var t = this.formatQueue(),
          i = function (i) {
            var n = t[i],
              s = new Date().getTime();
            n.data && I(n.data) && W(n.data, e => {
              e.offset = Math.abs(e.timestamp - s), delete e.timestamp;
            }), e.sendRequest(n);
          };
        for (var n in t) i(n);
      }
    }, this.flushTimeoutMs));
  }
  clearFlushTimeout() {
    clearTimeout(this.flushTimeout), this.flushTimeout = void 0;
  }
  formatQueue() {
    var e = {};
    return W(this.queue, i => {
      var n,
        s = i,
        r = (s ? s.batchKey : null) || s.url;
      F(e[r]) && (e[r] = t(t({}, s), {}, {
        data: []
      })), null === (n = e[r].data) || void 0 === n || n.push(s.data);
    }), this.queue = [], e;
  }
}
var ss = !!v || !!p,
  rs = "text/plain",
  os = (e, i) => {
    var [n, s] = e.split("?"),
      r = t({}, i);
    null == s || s.split("&").forEach(e => {
      var [t] = e.split("=");
      delete r[t];
    });
    var o = _t(r);
    return o = o ? (s ? s + "&" : "") + o : s, "".concat(n, "?").concat(o);
  },
  as = (e, t) => JSON.stringify(e, (e, t) => "bigint" == typeof t ? t.toString() : t, t),
  ls = e => {
    var {
      data: t,
      compression: i
    } = e;
    if (t) {
      if (i === s.GZipJS) {
        var n = Un(zn(as(t)), {
            mtime: 0
          }),
          r = new Blob([n], {
            type: rs
          });
        return {
          contentType: rs,
          body: r,
          estimatedSize: r.size
        };
      }
      if (i === s.Base64) {
        var o = function (e) {
            var t,
              i,
              n,
              s,
              r,
              o = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=",
              a = 0,
              l = 0,
              u = "",
              c = [];
            if (!e) return e;
            e = Z(e);
            do {
              t = (r = e.charCodeAt(a++) << 16 | e.charCodeAt(a++) << 8 | e.charCodeAt(a++)) >> 18 & 63, i = r >> 12 & 63, n = r >> 6 & 63, s = 63 & r, c[l++] = o.charAt(t) + o.charAt(i) + o.charAt(n) + o.charAt(s);
            } while (a < e.length);
            switch (u = c.join(""), e.length % 3) {
              case 1:
                u = u.slice(0, -2) + "==";
                break;
              case 2:
                u = u.slice(0, -1) + "=";
            }
            return u;
          }(as(t)),
          a = (e => "data=" + encodeURIComponent("string" == typeof e ? e : as(e)))(o);
        return {
          contentType: "application/x-www-form-urlencoded",
          body: a,
          estimatedSize: new Blob([a]).size
        };
      }
      var l = as(t);
      return {
        contentType: "application/json",
        body: l,
        estimatedSize: new Blob([l]).size
      };
    }
  },
  us = [];
v && us.push({
  transport: "XHR",
  method: e => {
    var t,
      i = new v();
    i.open(e.method || "GET", e.url, !0);
    var {
      contentType: n,
      body: s
    } = null !== (t = ls(e)) && void 0 !== t ? t : {};
    W(e.headers, function (e, t) {
      i.setRequestHeader(t, e);
    }), n && i.setRequestHeader("Content-Type", n), e.timeout && (i.timeout = e.timeout), i.withCredentials = !0, i.onreadystatechange = () => {
      if (4 === i.readyState) {
        var t,
          n = {
            statusCode: i.status,
            text: i.responseText
          };
        if (200 === i.status) try {
          n.json = JSON.parse(i.responseText);
        } catch (e) {}
        null === (t = e.callback) || void 0 === t || t.call(e, n);
      }
    }, i.send(s);
  }
}), p && us.push({
  transport: "fetch",
  method: e => {
    var t,
      i,
      {
        contentType: n,
        body: s,
        estimatedSize: r
      } = null !== (t = ls(e)) && void 0 !== t ? t : {},
      o = new Headers();
    W(e.headers, function (e, t) {
      o.append(t, e);
    }), n && o.append("Content-Type", n);
    var a = e.url,
      l = null;
    if (g) {
      var u = new g();
      l = {
        signal: u.signal,
        timeout: setTimeout(() => u.abort(), e.timeout)
      };
    }
    p(a, {
      method: (null == e ? void 0 : e.method) || "GET",
      headers: o,
      keepalive: "POST" === e.method && (r || 0) < 52428.8,
      body: s,
      signal: null === (i = l) || void 0 === i ? void 0 : i.signal
    }).then(t => t.text().then(i => {
      var n,
        s = {
          statusCode: t.status,
          text: i
        };
      if (200 === t.status) try {
        s.json = JSON.parse(i);
      } catch (e) {
        B.error(e);
      }
      null === (n = e.callback) || void 0 === n || n.call(e, s);
    })).catch(t => {
      var i;
      B.error(t), null === (i = e.callback) || void 0 === i || i.call(e, {
        statusCode: 0,
        text: t
      });
    }).finally(() => l ? clearTimeout(l.timeout) : null);
  }
}), null != d && d.sendBeacon && us.push({
  transport: "sendBeacon",
  method: e => {
    var t = os(e.url, {
      beacon: "1"
    });
    try {
      var i,
        {
          contentType: n,
          body: s
        } = null !== (i = ls(e)) && void 0 !== i ? i : {},
        r = "string" == typeof s ? new Blob([s], {
          type: n
        }) : s;
      d.sendBeacon(t, r);
    } catch (e) {}
  }
});
var cs = ["retriesPerformedSoFar"];
class ds {
  constructor(e) {
    i(this, "isPolling", !1), i(this, "pollIntervalMs", 3e3), i(this, "queue", []), this.instance = e, this.queue = [], this.areWeOnline = !0, !F(o) && "onLine" in o.navigator && (this.areWeOnline = o.navigator.onLine, o.addEventListener("online", () => {
      this.areWeOnline = !0, this.flush();
    }), o.addEventListener("offline", () => {
      this.areWeOnline = !1;
    }));
  }
  retriableRequest(e) {
    var {
        retriesPerformedSoFar: i
      } = e,
      s = n(e, cs);
    A(i) && i > 0 && (s.url = os(s.url, {
      retry_count: i
    })), this.instance._send_request(t(t({}, s), {}, {
      callback: e => {
        var n;
        200 !== e.statusCode && (e.statusCode < 400 || e.statusCode >= 500) && (null != i ? i : 0) < 10 ? this.enqueue(t({
          retriesPerformedSoFar: i
        }, s)) : null === (n = s.callback) || void 0 === n || n.call(s, e);
      }
    }));
  }
  enqueue(e) {
    var t = e.retriesPerformedSoFar || 0;
    e.retriesPerformedSoFar = t + 1;
    var i = function (e) {
        var t = 3e3 * Math.pow(2, e),
          i = t / 2,
          n = Math.min(18e5, t),
          s = (Math.random() - .5) * (n - i);
        return Math.ceil(n + s);
      }(t),
      n = Date.now() + i;
    this.queue.push({
      retryAt: n,
      requestOptions: e
    });
    var s = "Enqueued failed request for retry in ".concat(i);
    navigator.onLine || (s += " (Browser is offline)"), B.warn(s), this.isPolling || (this.isPolling = !0, this.poll());
  }
  poll() {
    this.poller && clearTimeout(this.poller), this.poller = setTimeout(() => {
      this.areWeOnline && this.queue.length > 0 && this.flush(), this.poll();
    }, this.pollIntervalMs);
  }
  flush() {
    var e = Date.now(),
      t = [],
      i = this.queue.filter(i => i.retryAt < e || (t.push(i), !1));
    if (this.queue = t, i.length > 0) for (var {
      requestOptions: n
    } of i) this.retriableRequest(n);
  }
  unload() {
    for (var {
      requestOptions: e
    } of (this.poller && (clearTimeout(this.poller), this.poller = void 0), this.queue)) try {
      this.instance._send_request(t(t({}, e), {}, {
        transport: "sendBeacon"
      }));
    } catch (e) {
      B.error(e);
    }
    this.queue = [];
  }
}
var hs;
class _s {
  constructor(e, t, n) {
    var s;
    if (i(this, "_sessionIdChangedHandlers", []), !e.persistence) throw new Error("SessionIdManager requires a PostHogPersistence instance");
    this.config = e.config, this.persistence = e.persistence, this._windowId = void 0, this._sessionId = void 0, this._sessionStartTimestamp = null, this._sessionActivityTimestamp = null, this._sessionIdGenerator = t || Qe, this._windowIdGenerator = n || Qe;
    var r = this.config.persistence_name || this.config.token,
      o = this.config.session_idle_timeout_seconds || 1800;
    if (this._sessionTimeoutMs = 1e3 * sn(o, 60, 36e3, "session_idle_timeout_seconds", 1800), e.register({
      $configured_session_timeout_ms: this._sessionTimeoutMs
    }), this._window_id_storage_key = "ph_" + r + "_window_id", this._primary_window_exists_storage_key = "ph_" + r + "_primary_window_exists", this._canUseSessionStorage()) {
      var a = ut.parse(this._window_id_storage_key),
        l = ut.parse(this._primary_window_exists_storage_key);
      a && !l ? this._windowId = a : ut.remove(this._window_id_storage_key), ut.set(this._primary_window_exists_storage_key, !0);
    }
    if (null !== (s = this.config.bootstrap) && void 0 !== s && s.sessionID) try {
      var u = (e => {
        var t = e.replace(/-/g, "");
        if (32 !== t.length) throw new Error("Not a valid UUID");
        if ("7" !== t[12]) throw new Error("Not a UUIDv7");
        return parseInt(t.substring(0, 12), 16);
      })(this.config.bootstrap.sessionID);
      this._setSessionId(this.config.bootstrap.sessionID, new Date().getTime(), u);
    } catch (e) {
      B.error("Invalid sessionID in bootstrap", e);
    }
    this._listenToReloadWindow();
  }
  get sessionTimeoutMs() {
    return this._sessionTimeoutMs;
  }
  onSessionId(e) {
    return F(this._sessionIdChangedHandlers) && (this._sessionIdChangedHandlers = []), this._sessionIdChangedHandlers.push(e), this._sessionId && e(this._sessionId, this._windowId), () => {
      this._sessionIdChangedHandlers = this._sessionIdChangedHandlers.filter(t => t !== e);
    };
  }
  _canUseSessionStorage() {
    return "memory" !== this.config.persistence && !this.persistence.disabled && ut.is_supported();
  }
  _setWindowId(e) {
    e !== this._windowId && (this._windowId = e, this._canUseSessionStorage() && ut.set(this._window_id_storage_key, e));
  }
  _getWindowId() {
    return this._windowId ? this._windowId : this._canUseSessionStorage() ? ut.parse(this._window_id_storage_key) : null;
  }
  _setSessionId(e, t, i) {
    e === this._sessionId && t === this._sessionActivityTimestamp && i === this._sessionStartTimestamp || (this._sessionStartTimestamp = i, this._sessionActivityTimestamp = t, this._sessionId = e, this.persistence.register({
      [me]: [t, e, i]
    }));
  }
  _getSessionId() {
    if (this._sessionId && this._sessionActivityTimestamp && this._sessionStartTimestamp) return [this._sessionActivityTimestamp, this._sessionId, this._sessionStartTimestamp];
    var e = this.persistence.props[me];
    return I(e) && 2 === e.length && e.push(e[0]), e || [0, null, 0];
  }
  resetSessionId() {
    this._setSessionId(null, null, null);
  }
  _listenToReloadWindow() {
    null == o || o.addEventListener("beforeunload", () => {
      this._canUseSessionStorage() && ut.remove(this._primary_window_exists_storage_key);
    });
  }
  checkAndGetSessionAndWindowId() {
    var e = arguments.length > 0 && void 0 !== arguments[0] && arguments[0],
      t = (arguments.length > 1 && void 0 !== arguments[1] ? arguments[1] : null) || new Date().getTime(),
      [i, n, s] = this._getSessionId(),
      r = this._getWindowId(),
      o = A(s) && s > 0 && Math.abs(t - s) > 864e5,
      a = !1,
      l = !n,
      u = !e && Math.abs(t - i) > this.sessionTimeoutMs;
    l || u || o ? (n = this._sessionIdGenerator(), r = this._windowIdGenerator(), B.info("[SessionId] new session ID generated", {
      sessionId: n,
      windowId: r,
      changeReason: {
        noSessionId: l,
        activityTimeout: u,
        sessionPastMaximumLength: o
      }
    }), s = t, a = !0) : r || (r = this._windowIdGenerator(), a = !0);
    var c = 0 === i || !e || o ? t : i,
      d = 0 === s ? new Date().getTime() : s;
    return this._setWindowId(r), this._setSessionId(n, c, d), a && this._sessionIdChangedHandlers.forEach(e => e(n, r, a ? {
      noSessionId: l,
      activityTimeout: u,
      sessionPastMaximumLength: o
    } : void 0)), {
      sessionId: n,
      windowId: r,
      sessionStartTimestamp: d,
      changeReason: a ? {
        noSessionId: l,
        activityTimeout: u,
        sessionPastMaximumLength: o
      } : void 0,
      lastActivityTimestamp: i
    };
  }
}
!function (e) {
  e.US = "us", e.EU = "eu", e.CUSTOM = "custom";
}(hs || (hs = {}));
var ps = "i.posthog.com";
class vs {
  constructor(e) {
    i(this, "_regionCache", {}), this.instance = e;
  }
  get apiHost() {
    var e = this.instance.config.api_host.trim().replace(/\/$/, "");
    return "https://app.posthog.com" === e ? "https://us.i.posthog.com" : e;
  }
  get uiHost() {
    var e,
      t = null === (e = this.instance.config.ui_host) || void 0 === e ? void 0 : e.replace(/\/$/, "");
    return t || (t = this.apiHost.replace(".".concat(ps), ".posthog.com")), "https://app.posthog.com" === t ? "https://us.posthog.com" : t;
  }
  get region() {
    return this._regionCache[this.apiHost] || (/https:\/\/(app|us|us-assets)(\.i)?\.posthog\.com/i.test(this.apiHost) ? this._regionCache[this.apiHost] = hs.US : /https:\/\/(eu|eu-assets)(\.i)?\.posthog\.com/i.test(this.apiHost) ? this._regionCache[this.apiHost] = hs.EU : this._regionCache[this.apiHost] = hs.CUSTOM), this._regionCache[this.apiHost];
  }
  endpointFor(e) {
    var t = arguments.length > 1 && void 0 !== arguments[1] ? arguments[1] : "";
    if (t && (t = "/" === t[0] ? t : "/".concat(t)), "ui" === e) return this.uiHost + t;
    if (this.region === hs.CUSTOM) return this.apiHost + t;
    var i = ps + t;
    switch (e) {
      case "assets":
        return "https://".concat(this.region, "-assets.").concat(i);
      case "api":
        return "https://".concat(this.region, ".").concat(i);
    }
  }
}
var gs = "posthog-js";
function fs(e) {
  var {
    organization: t,
    projectId: i,
    prefix: n,
    severityAllowList: s = ["error"]
  } = arguments.length > 1 && void 0 !== arguments[1] ? arguments[1] : {};
  return r => {
    var o, a, l, u, c;
    if (!("*" === s || s.includes(r.level)) || !e.__loaded) return r;
    r.tags || (r.tags = {});
    var d = e.requestRouter.endpointFor("ui", "/project/".concat(e.config.token, "/person/").concat(e.get_distinct_id()));
    r.tags["PostHog Person URL"] = d, e.sessionRecordingStarted() && (r.tags["PostHog Recording URL"] = e.get_session_replay_url({
      withTimestamp: !0
    }));
    var h = (null === (o = r.exception) || void 0 === o ? void 0 : o.values) || [];
    h.map(e => {
      e.stacktrace && (e.stacktrace.type = "raw");
    });
    var _ = {
      $exception_message: (null === (a = h[0]) || void 0 === a ? void 0 : a.value) || r.message,
      $exception_type: null === (l = h[0]) || void 0 === l ? void 0 : l.type,
      $exception_personURL: d,
      $exception_level: r.level,
      $exception_list: h,
      $sentry_event_id: r.event_id,
      $sentry_exception: r.exception,
      $sentry_exception_message: (null === (u = h[0]) || void 0 === u ? void 0 : u.value) || r.message,
      $sentry_exception_type: null === (c = h[0]) || void 0 === c ? void 0 : c.type,
      $sentry_tags: r.tags
    };
    return t && i && (_.$sentry_url = (n || "https://sentry.io/organizations/") + t + "/issues/?project=" + i + "&query=" + r.event_id), e.exceptions.sendExceptionEvent(_), r;
  };
}
class ms {
  constructor(e, t, i, n, s) {
    this.name = gs, this.setupOnce = function (r) {
      r(fs(e, {
        organization: t,
        projectId: i,
        prefix: n,
        severityAllowList: s
      }));
    };
  }
}
var bs, ys, ws;
function Ss(e, t) {
  var i = e.config.segment;
  if (!i) return t();
  !function (e, t) {
    var i = e.config.segment;
    if (!i) return t();
    var n = i => {
        var n = () => i.anonymousId() || Qe();
        e.config.get_device_id = n, i.id() && (e.register({
          distinct_id: i.id(),
          $device_id: n()
        }), e.persistence.set_property(Re, "identified")), t();
      },
      s = i.user();
    "then" in s && C(s.then) ? s.then(e => n(e)) : n(s);
  }(e, () => {
    i.register((e => {
      Promise && Promise.resolve || B.warn("This browser does not have Promise support, and can not use the segment integration");
      var t = (t, i) => {
        var n;
        if (!i) return t;
        t.event.userId || t.event.anonymousId === e.get_distinct_id() || (B.info("Segment integration does not have a userId set, resetting PostHog"), e.reset()), t.event.userId && t.event.userId !== e.get_distinct_id() && (B.info("Segment integration has a userId set, identifying with PostHog"), e.identify(t.event.userId));
        var s = e._calculate_event_properties(i, null !== (n = t.event.properties) && void 0 !== n ? n : {}, new Date());
        return t.event.properties = Object.assign({}, s, t.event.properties), t;
      };
      return {
        name: "PostHog JS",
        type: "enrichment",
        version: "1.0.0",
        isLoaded: () => !0,
        load: () => Promise.resolve(),
        track: e => t(e, e.event.event),
        page: e => t(e, "$pageview"),
        identify: e => t(e, "$identify"),
        screen: e => t(e, "$screen")
      };
    })(e)).then(() => {
      t();
    });
  });
}
class Es {
  constructor(e) {
    this._instance = e;
  }
  doPageView(e) {
    var t,
      i = this._previousPageViewProperties(e);
    return this._currentPath = null !== (t = null == o ? void 0 : o.location.pathname) && void 0 !== t ? t : "", this._instance.scrollManager.resetContext(), this._prevPageviewTimestamp = e, i;
  }
  doPageLeave(e) {
    return this._previousPageViewProperties(e);
  }
  _previousPageViewProperties(e) {
    var t = this._currentPath,
      i = this._prevPageviewTimestamp,
      n = this._instance.scrollManager.getContext();
    if (!i) return {};
    var s = {};
    if (n) {
      var {
        maxScrollHeight: r,
        lastScrollY: o,
        maxScrollY: a,
        maxContentHeight: l,
        lastContentY: u,
        maxContentY: c
      } = n;
      if (!(F(r) || F(o) || F(a) || F(l) || F(u) || F(c))) r = Math.ceil(r), o = Math.ceil(o), a = Math.ceil(a), l = Math.ceil(l), u = Math.ceil(u), c = Math.ceil(c), s = {
        $prev_pageview_last_scroll: o,
        $prev_pageview_last_scroll_percentage: r <= 1 ? 1 : sn(o / r, 0, 1),
        $prev_pageview_max_scroll: a,
        $prev_pageview_max_scroll_percentage: r <= 1 ? 1 : sn(a / r, 0, 1),
        $prev_pageview_last_content: u,
        $prev_pageview_last_content_percentage: l <= 1 ? 1 : sn(u / l, 0, 1),
        $prev_pageview_max_content: c,
        $prev_pageview_max_content_percentage: l <= 1 ? 1 : sn(c / l, 0, 1)
      };
    }
    return t && (s.$prev_pageview_pathname = t), i && (s.$prev_pageview_duration = (e.getTime() - i.getTime()) / 1e3), s;
  }
}
!function (e) {
  e.Popover = "popover", e.API = "api", e.Widget = "widget";
}(bs || (exports.SurveyType = bs = {})), function (e) {
  e.Open = "open", e.MultipleChoice = "multiple_choice", e.SingleChoice = "single_choice", e.Rating = "rating", e.Link = "link";
}(ys || (exports.SurveyQuestionType = ys = {})), function (e) {
  e.NextQuestion = "next_question", e.End = "end", e.ResponseBased = "response_based", e.SpecificQuestion = "specific_question";
}(ws || (exports.SurveyQuestionBranchingType = ws = {}));
class ks {
  constructor() {
    i(this, "events", {}), this.events = {};
  }
  on(e, t) {
    return this.events[e] || (this.events[e] = []), this.events[e].push(t), () => {
      this.events[e] = this.events[e].filter(e => e !== t);
    };
  }
  emit(e, t) {
    for (var i of this.events[e] || []) i(t);
    for (var n of this.events["*"] || []) n(e, t);
  }
}
class xs {
  constructor(e) {
    i(this, "_debugEventEmitter", new ks()), i(this, "checkStep", (e, t) => this.checkStepEvent(e, t) && this.checkStepUrl(e, t) && this.checkStepElement(e, t)), i(this, "checkStepEvent", (e, t) => null == t || !t.event || (null == e ? void 0 : e.event) === (null == t ? void 0 : t.event)), this.instance = e, this.actionEvents = new Set(), this.actionRegistry = new Set();
  }
  init() {
    var e;
    if (!F(null === (e = this.instance) || void 0 === e ? void 0 : e._addCaptureHook)) {
      var t;
      null === (t = this.instance) || void 0 === t || t._addCaptureHook((e, t) => {
        this.on(e, t);
      });
    }
  }
  register(e) {
    var t, i;
    if (!F(null === (t = this.instance) || void 0 === t ? void 0 : t._addCaptureHook) && (e.forEach(e => {
      var t, i;
      null === (t = this.actionRegistry) || void 0 === t || t.add(e), null === (i = e.steps) || void 0 === i || i.forEach(e => {
        var t;
        null === (t = this.actionEvents) || void 0 === t || t.add((null == e ? void 0 : e.event) || "");
      });
    }), null !== (i = this.instance) && void 0 !== i && i.autocapture)) {
      var n,
        s = new Set();
      e.forEach(e => {
        var t;
        null === (t = e.steps) || void 0 === t || t.forEach(e => {
          null != e && e.selector && s.add(null == e ? void 0 : e.selector);
        });
      }), null === (n = this.instance) || void 0 === n || n.autocapture.setElementSelectors(s);
    }
  }
  on(e, t) {
    var i;
    null != t && 0 != e.length && (this.actionEvents.has(e) || this.actionEvents.has(null == t ? void 0 : t.event)) && this.actionRegistry && (null === (i = this.actionRegistry) || void 0 === i ? void 0 : i.size) > 0 && this.actionRegistry.forEach(e => {
      this.checkAction(t, e) && this._debugEventEmitter.emit("actionCaptured", e.name);
    });
  }
  _addActionHook(e) {
    this.onAction("actionCaptured", t => e(t));
  }
  checkAction(e, t) {
    if (null == (null == t ? void 0 : t.steps)) return !1;
    for (var i of t.steps) if (this.checkStep(e, i)) return !0;
    return !1;
  }
  onAction(e, t) {
    return this._debugEventEmitter.on(e, t);
  }
  checkStepUrl(e, t) {
    if (null != t && t.url) {
      var i,
        n = null == e || null === (i = e.properties) || void 0 === i ? void 0 : i.$current_url;
      if (!n || "string" != typeof n) return !1;
      if (!xs.matchString(n, null == t ? void 0 : t.url, (null == t ? void 0 : t.url_matching) || "contains")) return !1;
    }
    return !0;
  }
  static matchString(e, t, i) {
    switch (i) {
      case "regex":
        return !!o && ht(e, t);
      case "exact":
        return t === e;
      case "contains":
        var n = xs.escapeStringRegexp(t).replace(/_/g, ".").replace(/%/g, ".*");
        return ht(e, n);
      default:
        return !1;
    }
  }
  static escapeStringRegexp(e) {
    return e.replace(/[|\\{}()[\]^$+*?.]/g, "\\$&").replace(/-/g, "\\x2d");
  }
  checkStepElement(e, t) {
    if ((null != t && t.href || null != t && t.tag_name || null != t && t.text) && !this.getElementsList(e).some(e => !(null != t && t.href && !xs.matchString(e.href || "", null == t ? void 0 : t.href, (null == t ? void 0 : t.href_matching) || "exact")) && (null == t || !t.tag_name || e.tag_name === (null == t ? void 0 : t.tag_name)) && !(null != t && t.text && !xs.matchString(e.text || "", null == t ? void 0 : t.text, (null == t ? void 0 : t.text_matching) || "exact") && !xs.matchString(e.$el_text || "", null == t ? void 0 : t.text, (null == t ? void 0 : t.text_matching) || "exact")))) return !1;
    if (null != t && t.selector) {
      var i,
        n = null == e || null === (i = e.properties) || void 0 === i ? void 0 : i.$element_selectors;
      if (!n) return !1;
      if (!n.includes(null == t ? void 0 : t.selector)) return !1;
    }
    return !0;
  }
  getElementsList(e) {
    return null == (null == e ? void 0 : e.properties.$elements) ? [] : null == e ? void 0 : e.properties.$elements;
  }
}
class Is {
  constructor(e) {
    this.instance = e, this.eventToSurveys = new Map(), this.actionToSurveys = new Map();
  }
  register(e) {
    var t;
    F(null === (t = this.instance) || void 0 === t ? void 0 : t._addCaptureHook) || (this.setupEventBasedSurveys(e), this.setupActionBasedSurveys(e));
  }
  setupActionBasedSurveys(e) {
    var t = e.filter(e => {
      var t, i, n, s;
      return (null === (t = e.conditions) || void 0 === t ? void 0 : t.actions) && (null === (i = e.conditions) || void 0 === i || null === (n = i.actions) || void 0 === n || null === (s = n.values) || void 0 === s ? void 0 : s.length) > 0;
    });
    if (0 !== t.length) {
      if (null == this.actionMatcher) {
        this.actionMatcher = new xs(this.instance), this.actionMatcher.init();
        this.actionMatcher._addActionHook(e => {
          this.onAction(e);
        });
      }
      t.forEach(e => {
        var t, i, n, s, r, o, a, l, u, c;
        e.conditions && null !== (t = e.conditions) && void 0 !== t && t.actions && null !== (i = e.conditions) && void 0 !== i && null !== (n = i.actions) && void 0 !== n && n.values && (null === (s = e.conditions) || void 0 === s || null === (r = s.actions) || void 0 === r || null === (o = r.values) || void 0 === o ? void 0 : o.length) > 0 && (null === (a = this.actionMatcher) || void 0 === a || a.register(e.conditions.actions.values), null === (l = e.conditions) || void 0 === l || null === (u = l.actions) || void 0 === u || null === (c = u.values) || void 0 === c || c.forEach(t => {
          if (t && t.name) {
            var i = this.actionToSurveys.get(t.name);
            i && i.push(e.id), this.actionToSurveys.set(t.name, i || [e.id]);
          }
        }));
      });
    }
  }
  setupEventBasedSurveys(e) {
    var t;
    if (0 !== e.filter(e => {
      var t, i, n, s;
      return (null === (t = e.conditions) || void 0 === t ? void 0 : t.events) && (null === (i = e.conditions) || void 0 === i || null === (n = i.events) || void 0 === n || null === (s = n.values) || void 0 === s ? void 0 : s.length) > 0;
    }).length) {
      null === (t = this.instance) || void 0 === t || t._addCaptureHook((e, t) => {
        this.onEvent(e, t);
      }), e.forEach(e => {
        var t, i, n;
        null === (t = e.conditions) || void 0 === t || null === (i = t.events) || void 0 === i || null === (n = i.values) || void 0 === n || n.forEach(t => {
          if (t && t.name) {
            var i = this.eventToSurveys.get(t.name);
            i && i.push(e.id), this.eventToSurveys.set(t.name, i || [e.id]);
          }
        });
      });
    }
  }
  onEvent(e, t) {
    var i,
      n,
      s = (null === (i = this.instance) || void 0 === i || null === (n = i.persistence) || void 0 === n ? void 0 : n.props[Ce]) || [];
    if (Is.SURVEY_SHOWN_EVENT_NAME == e && t && s.length > 0) {
      var r,
        o = null == t || null === (r = t.properties) || void 0 === r ? void 0 : r.$survey_id;
      if (o) {
        var a = s.indexOf(o);
        a >= 0 && (s.splice(a, 1), this._updateActivatedSurveys(s));
      }
    } else this.eventToSurveys.has(e) && this._updateActivatedSurveys(s.concat(this.eventToSurveys.get(e) || []));
  }
  onAction(e) {
    var t,
      i,
      n = (null === (t = this.instance) || void 0 === t || null === (i = t.persistence) || void 0 === i ? void 0 : i.props[Ce]) || [];
    this.actionToSurveys.has(e) && this._updateActivatedSurveys(n.concat(this.actionToSurveys.get(e) || []));
  }
  _updateActivatedSurveys(e) {
    var t, i;
    null === (t = this.instance) || void 0 === t || null === (i = t.persistence) || void 0 === i || i.register({
      [Ce]: [...new Set(e)]
    });
  }
  getSurveys() {
    var e,
      t,
      i = null === (e = this.instance) || void 0 === e || null === (t = e.persistence) || void 0 === t ? void 0 : t.props[Ce];
    return i || [];
  }
  getEventToSurveys() {
    return this.eventToSurveys;
  }
  _getActionMatcher() {
    return this.actionMatcher;
  }
}
i(Is, "SURVEY_SHOWN_EVENT_NAME", "survey shown");
var Cs,
  Ps,
  Rs,
  Fs,
  Ts,
  $s,
  Os,
  Ms,
  As = {},
  Ls = [],
  Ds = /acit|ex(?:s|g|n|p|$)|rph|grid|ows|mnc|ntw|ine[ch]|zoo|^ord|itera/i,
  Ns = Array.isArray;
function qs(e, t) {
  for (var i in t) e[i] = t[i];
  return e;
}
function Bs(e) {
  var t = e.parentNode;
  t && t.removeChild(e);
}
function Hs(e, t, i, n, s) {
  var r = {
    type: e,
    props: t,
    key: i,
    ref: n,
    __k: null,
    __: null,
    __b: 0,
    __e: null,
    __d: void 0,
    __c: null,
    constructor: void 0,
    __v: null == s ? ++Rs : s,
    __i: -1,
    __u: 0
  };
  return null == s && null != Ps.vnode && Ps.vnode(r), r;
}
function Us(e) {
  return e.children;
}
function zs(e, t) {
  this.props = e, this.context = t;
}
function Ws(e, t) {
  if (null == t) return e.__ ? Ws(e.__, e.__i + 1) : null;
  for (var i; t < e.__k.length; t++) if (null != (i = e.__k[t]) && null != i.__e) return i.__e;
  return "function" == typeof e.type ? Ws(e) : null;
}
function js(e) {
  var t, i;
  if (null != (e = e.__) && null != e.__c) {
    for (e.__e = e.__c.base = null, t = 0; t < e.__k.length; t++) if (null != (i = e.__k[t]) && null != i.__e) {
      e.__e = e.__c.base = i.__e;
      break;
    }
    return js(e);
  }
}
function Gs(e) {
  (!e.__d && (e.__d = !0) && Fs.push(e) && !Vs.__r++ || Ts !== Ps.debounceRendering) && ((Ts = Ps.debounceRendering) || $s)(Vs);
}
function Vs() {
  var e, t, i, n, s, r, o, a, l;
  for (Fs.sort(Os); e = Fs.shift();) e.__d && (t = Fs.length, n = void 0, r = (s = (i = e).__v).__e, a = [], l = [], (o = i.__P) && ((n = qs({}, s)).__v = s.__v + 1, Ps.vnode && Ps.vnode(n), ir(o, n, s, i.__n, void 0 !== o.ownerSVGElement, 32 & s.__u ? [r] : null, a, null == r ? Ws(s) : r, !!(32 & s.__u), l), n.__.__k[n.__i] = n, nr(a, n, l), n.__e != r && js(n)), Fs.length > t && Fs.sort(Os));
  Vs.__r = 0;
}
function Js(e, t, i, n, s, r, o, a, l, u, c) {
  var d,
    h,
    _,
    p,
    v,
    g = n && n.__k || Ls,
    f = t.length;
  for (i.__d = l, Qs(i, t, g), l = i.__d, d = 0; d < f; d++) null != (_ = i.__k[d]) && "boolean" != typeof _ && "function" != typeof _ && (h = -1 === _.__i ? As : g[_.__i] || As, _.__i = d, ir(e, _, h, s, r, o, a, l, u, c), p = _.__e, _.ref && h.ref != _.ref && (h.ref && rr(h.ref, null, _), c.push(_.ref, _.__c || p, _)), null == v && null != p && (v = p), 65536 & _.__u || h.__k === _.__k ? l = Ys(_, l, e) : "function" == typeof _.type && void 0 !== _.__d ? l = _.__d : p && (l = p.nextSibling), _.__d = void 0, _.__u &= -196609);
  i.__d = l, i.__e = v;
}
function Qs(e, t, i) {
  var n,
    s,
    r,
    o,
    a,
    l = t.length,
    u = i.length,
    c = u,
    d = 0;
  for (e.__k = [], n = 0; n < l; n++) null != (s = e.__k[n] = null == (s = t[n]) || "boolean" == typeof s || "function" == typeof s ? null : "string" == typeof s || "number" == typeof s || "bigint" == typeof s || s.constructor == String ? Hs(null, s, null, null, s) : Ns(s) ? Hs(Us, {
    children: s
  }, null, null, null) : void 0 === s.constructor && s.__b > 0 ? Hs(s.type, s.props, s.key, s.ref ? s.ref : null, s.__v) : s) ? (s.__ = e, s.__b = e.__b + 1, a = Xs(s, i, o = n + d, c), s.__i = a, r = null, -1 !== a && (c--, (r = i[a]) && (r.__u |= 131072)), null == r || null === r.__v ? (-1 == a && d--, "function" != typeof s.type && (s.__u |= 65536)) : a !== o && (a === o + 1 ? d++ : a > o ? c > l - o ? d += a - o : d-- : d = a < o && a == o - 1 ? a - o : 0, a !== n + d && (s.__u |= 65536))) : (r = i[n]) && null == r.key && r.__e && (r.__e == e.__d && (e.__d = Ws(r)), or(r, r, !1), i[n] = null, c--);
  if (c) for (n = 0; n < u; n++) null != (r = i[n]) && 0 == (131072 & r.__u) && (r.__e == e.__d && (e.__d = Ws(r)), or(r, r));
}
function Ys(e, t, i) {
  var n, s;
  if ("function" == typeof e.type) {
    for (n = e.__k, s = 0; n && s < n.length; s++) n[s] && (n[s].__ = e, t = Ys(n[s], t, i));
    return t;
  }
  return e.__e != t && (i.insertBefore(e.__e, t || null), t = e.__e), t && t.nextSibling;
}
function Xs(e, t, i, n) {
  var s = e.key,
    r = e.type,
    o = i - 1,
    a = i + 1,
    l = t[i];
  if (null === l || l && s == l.key && r === l.type) return i;
  if (n > (null != l && 0 == (131072 & l.__u) ? 1 : 0)) for (; o >= 0 || a < t.length;) {
    if (o >= 0) {
      if ((l = t[o]) && 0 == (131072 & l.__u) && s == l.key && r === l.type) return o;
      o--;
    }
    if (a < t.length) {
      if ((l = t[a]) && 0 == (131072 & l.__u) && s == l.key && r === l.type) return a;
      a++;
    }
  }
  return -1;
}
function Ks(e, t, i) {
  "-" === t[0] ? e.setProperty(t, null == i ? "" : i) : e[t] = null == i ? "" : "number" != typeof i || Ds.test(t) ? i : i + "px";
}
function Zs(e, t, i, n, s) {
  var r;
  e: if ("style" === t) {
    if ("string" == typeof i) e.style.cssText = i;else {
      if ("string" == typeof n && (e.style.cssText = n = ""), n) for (t in n) i && t in i || Ks(e.style, t, "");
      if (i) for (t in i) n && i[t] === n[t] || Ks(e.style, t, i[t]);
    }
  } else if ("o" === t[0] && "n" === t[1]) r = t !== (t = t.replace(/(PointerCapture)$|Capture$/, "$1")), t = t.toLowerCase() in e ? t.toLowerCase().slice(2) : t.slice(2), e.l || (e.l = {}), e.l[t + r] = i, i ? n ? i.u = n.u : (i.u = Date.now(), e.addEventListener(t, r ? tr : er, r)) : e.removeEventListener(t, r ? tr : er, r);else {
    if (s) t = t.replace(/xlink(H|:h)/, "h").replace(/sName$/, "s");else if ("width" !== t && "height" !== t && "href" !== t && "list" !== t && "form" !== t && "tabIndex" !== t && "download" !== t && "rowSpan" !== t && "colSpan" !== t && "role" !== t && t in e) try {
      e[t] = null == i ? "" : i;
      break e;
    } catch (e) {}
    "function" == typeof i || (null == i || !1 === i && "-" !== t[4] ? e.removeAttribute(t) : e.setAttribute(t, i));
  }
}
function er(e) {
  var t = this.l[e.type + !1];
  if (e.t) {
    if (e.t <= t.u) return;
  } else e.t = Date.now();
  return t(Ps.event ? Ps.event(e) : e);
}
function tr(e) {
  return this.l[e.type + !0](Ps.event ? Ps.event(e) : e);
}
function ir(e, t, i, n, s, r, o, a, l, u) {
  var c,
    d,
    h,
    _,
    p,
    v,
    g,
    f,
    m,
    b,
    y,
    w,
    S,
    E,
    k,
    x = t.type;
  if (void 0 !== t.constructor) return null;
  128 & i.__u && (l = !!(32 & i.__u), r = [a = t.__e = i.__e]), (c = Ps.__b) && c(t);
  e: if ("function" == typeof x) try {
    if (f = t.props, m = (c = x.contextType) && n[c.__c], b = c ? m ? m.props.value : c.__ : n, i.__c ? g = (d = t.__c = i.__c).__ = d.__E : ("prototype" in x && x.prototype.render ? t.__c = d = new x(f, b) : (t.__c = d = new zs(f, b), d.constructor = x, d.render = ar), m && m.sub(d), d.props = f, d.state || (d.state = {}), d.context = b, d.__n = n, h = d.__d = !0, d.__h = [], d._sb = []), null == d.__s && (d.__s = d.state), null != x.getDerivedStateFromProps && (d.__s == d.state && (d.__s = qs({}, d.__s)), qs(d.__s, x.getDerivedStateFromProps(f, d.__s))), _ = d.props, p = d.state, d.__v = t, h) null == x.getDerivedStateFromProps && null != d.componentWillMount && d.componentWillMount(), null != d.componentDidMount && d.__h.push(d.componentDidMount);else {
      if (null == x.getDerivedStateFromProps && f !== _ && null != d.componentWillReceiveProps && d.componentWillReceiveProps(f, b), !d.__e && (null != d.shouldComponentUpdate && !1 === d.shouldComponentUpdate(f, d.__s, b) || t.__v === i.__v)) {
        for (t.__v !== i.__v && (d.props = f, d.state = d.__s, d.__d = !1), t.__e = i.__e, t.__k = i.__k, t.__k.forEach(function (e) {
          e && (e.__ = t);
        }), y = 0; y < d._sb.length; y++) d.__h.push(d._sb[y]);
        d._sb = [], d.__h.length && o.push(d);
        break e;
      }
      null != d.componentWillUpdate && d.componentWillUpdate(f, d.__s, b), null != d.componentDidUpdate && d.__h.push(function () {
        d.componentDidUpdate(_, p, v);
      });
    }
    if (d.context = b, d.props = f, d.__P = e, d.__e = !1, w = Ps.__r, S = 0, "prototype" in x && x.prototype.render) {
      for (d.state = d.__s, d.__d = !1, w && w(t), c = d.render(d.props, d.state, d.context), E = 0; E < d._sb.length; E++) d.__h.push(d._sb[E]);
      d._sb = [];
    } else do {
      d.__d = !1, w && w(t), c = d.render(d.props, d.state, d.context), d.state = d.__s;
    } while (d.__d && ++S < 25);
    d.state = d.__s, null != d.getChildContext && (n = qs(qs({}, n), d.getChildContext())), h || null == d.getSnapshotBeforeUpdate || (v = d.getSnapshotBeforeUpdate(_, p)), Js(e, Ns(k = null != c && c.type === Us && null == c.key ? c.props.children : c) ? k : [k], t, i, n, s, r, o, a, l, u), d.base = t.__e, t.__u &= -161, d.__h.length && o.push(d), g && (d.__E = d.__ = null);
  } catch (e) {
    t.__v = null, l || null != r ? (t.__e = a, t.__u |= l ? 160 : 32, r[r.indexOf(a)] = null) : (t.__e = i.__e, t.__k = i.__k), Ps.__e(e, t, i);
  } else null == r && t.__v === i.__v ? (t.__k = i.__k, t.__e = i.__e) : t.__e = sr(i.__e, t, i, n, s, r, o, l, u);
  (c = Ps.diffed) && c(t);
}
function nr(e, t, i) {
  t.__d = void 0;
  for (var n = 0; n < i.length; n++) rr(i[n], i[++n], i[++n]);
  Ps.__c && Ps.__c(t, e), e.some(function (t) {
    try {
      e = t.__h, t.__h = [], e.some(function (e) {
        e.call(t);
      });
    } catch (e) {
      Ps.__e(e, t.__v);
    }
  });
}
function sr(e, t, i, n, s, r, o, a, l) {
  var u,
    c,
    d,
    h,
    _,
    p,
    v,
    g = i.props,
    f = t.props,
    m = t.type;
  if ("svg" === m && (s = !0), null != r) for (u = 0; u < r.length; u++) if ((_ = r[u]) && "setAttribute" in _ == !!m && (m ? _.localName === m : 3 === _.nodeType)) {
    e = _, r[u] = null;
    break;
  }
  if (null == e) {
    if (null === m) return document.createTextNode(f);
    e = s ? document.createElementNS("http://www.w3.org/2000/svg", m) : document.createElement(m, f.is && f), r = null, a = !1;
  }
  if (null === m) g === f || a && e.data === f || (e.data = f);else {
    if (r = r && Cs.call(e.childNodes), g = i.props || As, !a && null != r) for (g = {}, u = 0; u < e.attributes.length; u++) g[(_ = e.attributes[u]).name] = _.value;
    for (u in g) _ = g[u], "children" == u || ("dangerouslySetInnerHTML" == u ? d = _ : "key" === u || u in f || Zs(e, u, null, _, s));
    for (u in f) _ = f[u], "children" == u ? h = _ : "dangerouslySetInnerHTML" == u ? c = _ : "value" == u ? p = _ : "checked" == u ? v = _ : "key" === u || a && "function" != typeof _ || g[u] === _ || Zs(e, u, _, g[u], s);
    if (c) a || d && (c.__html === d.__html || c.__html === e.innerHTML) || (e.innerHTML = c.__html), t.__k = [];else if (d && (e.innerHTML = ""), Js(e, Ns(h) ? h : [h], t, i, n, s && "foreignObject" !== m, r, o, r ? r[0] : i.__k && Ws(i, 0), a, l), null != r) for (u = r.length; u--;) null != r[u] && Bs(r[u]);
    a || (u = "value", void 0 !== p && (p !== e[u] || "progress" === m && !p || "option" === m && p !== g[u]) && Zs(e, u, p, g[u], !1), u = "checked", void 0 !== v && v !== e[u] && Zs(e, u, v, g[u], !1));
  }
  return e;
}
function rr(e, t, i) {
  try {
    "function" == typeof e ? e(t) : e.current = t;
  } catch (e) {
    Ps.__e(e, i);
  }
}
function or(e, t, i) {
  var n, s;
  if (Ps.unmount && Ps.unmount(e), (n = e.ref) && (n.current && n.current !== e.__e || rr(n, null, t)), null != (n = e.__c)) {
    if (n.componentWillUnmount) try {
      n.componentWillUnmount();
    } catch (e) {
      Ps.__e(e, t);
    }
    n.base = n.__P = null, e.__c = void 0;
  }
  if (n = e.__k) for (s = 0; s < n.length; s++) n[s] && or(n[s], t, i || "function" != typeof e.type);
  i || null == e.__e || Bs(e.__e), e.__ = e.__e = e.__d = void 0;
}
function ar(e, t, i) {
  return this.constructor(e, i);
}
Cs = Ls.slice, Ps = {
  __e: function (e, t, i, n) {
    for (var s, r, o; t = t.__;) if ((s = t.__c) && !s.__) try {
      if ((r = s.constructor) && null != r.getDerivedStateFromError && (s.setState(r.getDerivedStateFromError(e)), o = s.__d), null != s.componentDidCatch && (s.componentDidCatch(e, n || {}), o = s.__d), o) return s.__E = s;
    } catch (t) {
      e = t;
    }
    throw e;
  }
}, Rs = 0, zs.prototype.setState = function (e, t) {
  var i;
  i = null != this.__s && this.__s !== this.state ? this.__s : this.__s = qs({}, this.state), "function" == typeof e && (e = e(qs({}, i), this.props)), e && qs(i, e), null != e && this.__v && (t && this._sb.push(t), Gs(this));
}, zs.prototype.forceUpdate = function (e) {
  this.__v && (this.__e = !0, e && this.__h.push(e), Gs(this));
}, zs.prototype.render = Us, Fs = [], $s = "function" == typeof Promise ? Promise.prototype.then.bind(Promise.resolve()) : setTimeout, Os = function (e, t) {
  return e.__v.__b - t.__v.__b;
}, Vs.__r = 0, Ms = 0;
!function (e, t) {
  var i = {
    __c: t = "__cC" + Ms++,
    __: e,
    Consumer: function (e, t) {
      return e.children(t);
    },
    Provider: function (e) {
      var i, n;
      return this.getChildContext || (i = [], (n = {})[t] = this, this.getChildContext = function () {
        return n;
      }, this.shouldComponentUpdate = function (e) {
        this.props.value !== e.value && i.some(function (e) {
          e.__e = !0, Gs(e);
        });
      }, this.sub = function (e) {
        i.push(e);
        var t = e.componentWillUnmount;
        e.componentWillUnmount = function () {
          i.splice(i.indexOf(e), 1), t && t.call(e);
        };
      }), e.children;
    }
  };
  i.Provider.__ = i.Consumer.contextType = i;
}({
  isPreviewMode: !1,
  previewPageIndex: 0,
  handleCloseSurveyPopup: () => {},
  isPopup: !0
});
var lr = "[Surveys]",
  ur = {
    icontains: e => !!o && o.location.href.toLowerCase().indexOf(e.toLowerCase()) > -1,
    not_icontains: e => !!o && -1 === o.location.href.toLowerCase().indexOf(e.toLowerCase()),
    regex: e => !!o && ht(o.location.href, e),
    not_regex: e => !!o && !ht(o.location.href, e),
    exact: e => (null == o ? void 0 : o.location.href) === e,
    is_not: e => (null == o ? void 0 : o.location.href) !== e
  };
class cr {
  constructor(e) {
    this.instance = e, this._surveyEventReceiver = null;
  }
  onRemoteConfig(e) {
    this._decideServerResponse = !!e.surveys, this.loadIfEnabled();
  }
  reset() {
    localStorage.removeItem("lastSeenSurveyDate");
    var e = (() => {
      for (var e = [], t = 0; t < localStorage.length; t++) {
        var i = localStorage.key(t);
        null != i && i.startsWith("seenSurvey_") && e.push(i);
      }
      return e;
    })();
    e.forEach(e => localStorage.removeItem(e));
  }
  loadIfEnabled() {
    var e,
      t,
      i,
      n = null == m || null === (e = m.__PosthogExtensions__) || void 0 === e ? void 0 : e.generateSurveys;
    this.instance.config.disable_surveys || !this._decideServerResponse || n || (null == this._surveyEventReceiver && (this._surveyEventReceiver = new Is(this.instance)), null === (t = m.__PosthogExtensions__) || void 0 === t || null === (i = t.loadExternalDependency) || void 0 === i || i.call(t, this.instance, "surveys", e => {
      var t, i;
      if (e) return B.error(lr, "Could not load surveys script", e);
      this._surveyManager = null === (t = m.__PosthogExtensions__) || void 0 === t || null === (i = t.generateSurveys) || void 0 === i ? void 0 : i.call(t, this.instance);
    }));
  }
  getSurveys(e) {
    var t = arguments.length > 1 && void 0 !== arguments[1] && arguments[1];
    if (this.instance.config.disable_surveys) return e([]);
    null == this._surveyEventReceiver && (this._surveyEventReceiver = new Is(this.instance));
    var i = this.instance.get_property(Ie);
    if (i && !t) return e(i);
    this.instance._send_request({
      url: this.instance.requestRouter.endpointFor("api", "/api/surveys/?token=".concat(this.instance.config.token)),
      method: "GET",
      transport: "XHR",
      callback: t => {
        var i;
        if (200 !== t.statusCode || !t.json) return e([]);
        var n,
          s = t.json.surveys || [],
          r = s.filter(e => {
            var t, i, n, s, r, o, a, l, u, c, d, h;
            return (null === (t = e.conditions) || void 0 === t ? void 0 : t.events) && (null === (i = e.conditions) || void 0 === i || null === (n = i.events) || void 0 === n ? void 0 : n.values) && (null === (s = e.conditions) || void 0 === s || null === (r = s.events) || void 0 === r || null === (o = r.values) || void 0 === o ? void 0 : o.length) > 0 || (null === (a = e.conditions) || void 0 === a ? void 0 : a.actions) && (null === (l = e.conditions) || void 0 === l || null === (u = l.actions) || void 0 === u ? void 0 : u.values) && (null === (c = e.conditions) || void 0 === c || null === (d = c.actions) || void 0 === d || null === (h = d.values) || void 0 === h ? void 0 : h.length) > 0;
          });
        r.length > 0 && (null === (n = this._surveyEventReceiver) || void 0 === n || n.register(r));
        return null === (i = this.instance.persistence) || void 0 === i || i.register({
          [Ie]: s
        }), e(s);
      }
    });
  }
  getActiveMatchingSurveys(e) {
    var t = arguments.length > 1 && void 0 !== arguments[1] && arguments[1];
    this.getSurveys(t => {
      var i,
        n = t.filter(e => !(!e.start_date || e.end_date)).filter(e => {
          var t, i, n, s;
          if (!e.conditions) return !0;
          var r = null === (t = e.conditions) || void 0 === t || !t.url || ur[null !== (i = null === (n = e.conditions) || void 0 === n ? void 0 : n.urlMatchType) && void 0 !== i ? i : "icontains"](e.conditions.url),
            o = null === (s = e.conditions) || void 0 === s || !s.selector || (null == h ? void 0 : h.querySelector(e.conditions.selector));
          return r && o;
        }),
        s = null === (i = this._surveyEventReceiver) || void 0 === i ? void 0 : i.getSurveys(),
        r = n.filter(e => {
          var t, i, n, r, o, a, l, u, c, d, h;
          if (!(e.linked_flag_key || e.targeting_flag_key || e.internal_targeting_flag_key || null !== (t = e.feature_flag_keys) && void 0 !== t && t.length)) return !0;
          var _ = !e.linked_flag_key || this.instance.featureFlags.isFeatureEnabled(e.linked_flag_key),
            p = !e.targeting_flag_key || this.instance.featureFlags.isFeatureEnabled(e.targeting_flag_key),
            v = (null === (i = e.conditions) || void 0 === i ? void 0 : i.events) && (null === (n = e.conditions) || void 0 === n || null === (r = n.events) || void 0 === r ? void 0 : r.values) && (null === (o = e.conditions) || void 0 === o || null === (a = o.events) || void 0 === a ? void 0 : a.values.length) > 0,
            g = (null === (l = e.conditions) || void 0 === l ? void 0 : l.actions) && (null === (u = e.conditions) || void 0 === u || null === (c = u.actions) || void 0 === c ? void 0 : c.values) && (null === (d = e.conditions) || void 0 === d || null === (h = d.actions) || void 0 === h ? void 0 : h.values.length) > 0,
            f = !v && !g || (null == s ? void 0 : s.includes(e.id)),
            m = this._canActivateRepeatedly(e),
            b = !(e.internal_targeting_flag_key && !m) || this.instance.featureFlags.isFeatureEnabled(e.internal_targeting_flag_key),
            y = this.checkFlags(e);
          return _ && p && b && f && y;
        });
      return e(r);
    }, t);
  }
  checkFlags(e) {
    var t;
    return null === (t = e.feature_flag_keys) || void 0 === t || !t.length || e.feature_flag_keys.every(e => {
      var {
        key: t,
        value: i
      } = e;
      return !t || !i || this.instance.featureFlags.isFeatureEnabled(i);
    });
  }
  getNextSurveyStep(e, t, i) {
    var n,
      s = e.questions[t],
      r = t + 1;
    if (null === (n = s.branching) || void 0 === n || !n.type) return t === e.questions.length - 1 ? ws.End : r;
    if (s.branching.type === ws.End) return ws.End;
    if (s.branching.type === ws.SpecificQuestion) {
      if (Number.isInteger(s.branching.index)) return s.branching.index;
    } else if (s.branching.type === ws.ResponseBased) {
      if (s.type === ys.SingleChoice) {
        var o,
          a,
          l = s.choices.indexOf("".concat(i));
        if (null !== (o = s.branching) && void 0 !== o && null !== (a = o.responseValues) && void 0 !== a && a.hasOwnProperty(l)) {
          var u = s.branching.responseValues[l];
          return Number.isInteger(u) ? u : u === ws.End ? ws.End : r;
        }
      } else if (s.type === ys.Rating) {
        var c, d;
        if ("number" != typeof i || !Number.isInteger(i)) throw new Error("The response type must be an integer");
        var h = function (e, t) {
          if (3 === t) {
            if (e < 1 || e > 3) throw new Error("The response must be in range 1-3");
            return 1 === e ? "negative" : 2 === e ? "neutral" : "positive";
          }
          if (5 === t) {
            if (e < 1 || e > 5) throw new Error("The response must be in range 1-5");
            return e <= 2 ? "negative" : 3 === e ? "neutral" : "positive";
          }
          if (7 === t) {
            if (e < 1 || e > 7) throw new Error("The response must be in range 1-7");
            return e <= 3 ? "negative" : 4 === e ? "neutral" : "positive";
          }
          if (10 === t) {
            if (e < 0 || e > 10) throw new Error("The response must be in range 0-10");
            return e <= 6 ? "detractors" : e <= 8 ? "passives" : "promoters";
          }
          throw new Error("The scale must be one of: 3, 5, 7, 10");
        }(i, s.scale);
        if (null !== (c = s.branching) && void 0 !== c && null !== (d = c.responseValues) && void 0 !== d && d.hasOwnProperty(h)) {
          var _ = s.branching.responseValues[h];
          return Number.isInteger(_) ? _ : _ === ws.End ? ws.End : r;
        }
      }
      return r;
    }
    return B.warn(lr, "Falling back to next question index due to unexpected branching type"), r;
  }
  _canActivateRepeatedly(e) {
    var t;
    return M(null === (t = m.__PosthogExtensions__) || void 0 === t ? void 0 : t.canActivateRepeatedly) ? (B.warn(lr, "canActivateRepeatedly is not defined, must init before calling"), !1) : m.__PosthogExtensions__.canActivateRepeatedly(e);
  }
  canRenderSurvey(e) {
    M(this._surveyManager) ? B.warn(lr, "canActivateRepeatedly is not defined, must init before calling") : this.getSurveys(t => {
      var i = t.filter(t => t.id === e)[0];
      this._surveyManager.canRenderSurvey(i);
    });
  }
  renderSurvey(e, t) {
    M(this._surveyManager) ? B.warn(lr, "canActivateRepeatedly is not defined, must init before calling") : this.getSurveys(i => {
      var n = i.filter(t => t.id === e)[0];
      this._surveyManager.renderSurvey(n, null == h ? void 0 : h.querySelector(t));
    });
  }
}
class dr {
  constructor(e) {
    var t, n;
    i(this, "serverLimits", {}), i(this, "lastEventRateLimited", !1), i(this, "checkForLimiting", e => {
      var t = e.text;
      if (t && t.length) try {
        (JSON.parse(t).quota_limited || []).forEach(e => {
          B.info("[RateLimiter] ".concat(e || "events", " is quota limited.")), this.serverLimits[e] = new Date().getTime() + 6e4;
        });
      } catch (e) {
        return void B.warn('[RateLimiter] could not rate limit - continuing. Error: "'.concat(null == e ? void 0 : e.message, '"'), {
          text: t
        });
      }
    }), this.instance = e, this.captureEventsPerSecond = (null === (t = e.config.rate_limiting) || void 0 === t ? void 0 : t.events_per_second) || 10, this.captureEventsBurstLimit = Math.max((null === (n = e.config.rate_limiting) || void 0 === n ? void 0 : n.events_burst_limit) || 10 * this.captureEventsPerSecond, this.captureEventsPerSecond), this.lastEventRateLimited = this.clientRateLimitContext(!0).isRateLimited;
  }
  clientRateLimitContext() {
    var e,
      t,
      i,
      n = arguments.length > 0 && void 0 !== arguments[0] && arguments[0],
      s = new Date().getTime(),
      r = null !== (e = null === (t = this.instance.persistence) || void 0 === t ? void 0 : t.get_property(Te)) && void 0 !== e ? e : {
        tokens: this.captureEventsBurstLimit,
        last: s
      };
    r.tokens += (s - r.last) / 1e3 * this.captureEventsPerSecond, r.last = s, r.tokens > this.captureEventsBurstLimit && (r.tokens = this.captureEventsBurstLimit);
    var o = r.tokens < 1;
    return o || n || (r.tokens = Math.max(0, r.tokens - 1)), !o || this.lastEventRateLimited || n || this.instance.capture("$$client_ingestion_warning", {
      $$client_ingestion_warning_message: "posthog-js client rate limited. Config is set to ".concat(this.captureEventsPerSecond, " events per second and ").concat(this.captureEventsBurstLimit, " events burst limit.")
    }, {
      skip_client_rate_limiting: !0
    }), this.lastEventRateLimited = o, null === (i = this.instance.persistence) || void 0 === i || i.set_property(Te, r), {
      isRateLimited: o,
      remainingTokens: r.tokens
    };
  }
  isServerRateLimited(e) {
    var t = this.serverLimits[e || "events"] || !1;
    return !1 !== t && new Date().getTime() < t;
  }
}
var hr = () => t({
  initialPathName: (null == _ ? void 0 : _.pathname) || "",
  referringDomain: _i.referringDomain()
}, _i.campaignParams());
class _r {
  constructor(e, t, n) {
    i(this, "_onSessionIdCallback", e => {
      var t = this._getStoredProps();
      if (!t || t.sessionId !== e) {
        var i = {
          sessionId: e,
          props: this._sessionSourceParamGenerator()
        };
        this._persistence.register({
          [Fe]: i
        });
      }
    }), this._sessionIdManager = e, this._persistence = t, this._sessionSourceParamGenerator = n || hr, this._sessionIdManager.onSessionId(this._onSessionIdCallback);
  }
  _getStoredProps() {
    return this._persistence.props[Fe];
  }
  getSessionProps() {
    var e,
      t = null === (e = this._getStoredProps()) || void 0 === e ? void 0 : e.props;
    return t ? {
      $client_session_initial_referring_host: t.referringDomain,
      $client_session_initial_pathname: t.initialPathName,
      $client_session_initial_utm_source: t.utm_source,
      $client_session_initial_utm_campaign: t.utm_campaign,
      $client_session_initial_utm_medium: t.utm_medium,
      $client_session_initial_utm_content: t.utm_content,
      $client_session_initial_utm_term: t.utm_term
    } : {};
  }
}
var pr = ["ahrefsbot", "ahrefssiteaudit", "applebot", "baiduspider", "bingbot", "bingpreview", "bot.htm", "bot.php", "crawler", "deepscan", "duckduckbot", "facebookexternal", "facebookcatalog", "gptbot", "http://yandex.com/bots", "hubspot", "ia_archiver", "linkedinbot", "mj12bot", "msnbot", "nessus", "petalbot", "pinterest", "prerender", "rogerbot", "screaming frog", "semrushbot", "sitebulb", "slurp", "turnitin", "twitterbot", "vercelbot", "yahoo! slurp", "yandexbot", "headlesschrome", "cypress", "Google-HotelAdsVerifier", "adsbot-google", "apis-google", "duplexweb-google", "feedfetcher-google", "google favicon", "google web preview", "google-read-aloud", "googlebot", "googleweblight", "mediapartners-google", "storebot-google", "Bytespider;"],
  vr = function (e, t) {
    if (!e) return !1;
    var i = e.toLowerCase();
    return pr.concat(t || []).some(e => {
      var t = e.toLowerCase();
      return -1 !== i.indexOf(t);
    });
  },
  gr = function (e, t) {
    if (!e) return !1;
    var i = e.userAgent;
    if (i && vr(i, t)) return !0;
    try {
      var n = null == e ? void 0 : e.userAgentData;
      if (null != n && n.brands && n.brands.some(e => vr(null == e ? void 0 : e.brand, t))) return !0;
    } catch (e) {}
    return !!e.webdriver;
  };
class fr {
  constructor() {
    this.clicks = [];
  }
  isRageClick(e, t, i) {
    var n = this.clicks[this.clicks.length - 1];
    if (n && Math.abs(e - n.x) + Math.abs(t - n.y) < 30 && i - n.timestamp < 1e3) {
      if (this.clicks.push({
        x: e,
        y: t,
        timestamp: i
      }), 3 === this.clicks.length) return !0;
    } else this.clicks = [{
      x: e,
      y: t,
      timestamp: i
    }];
    return !1;
  }
}
var mr = "[Dead Clicks]",
  br = () => !0,
  yr = e => {
    var t,
      i = !(null === (t = e.instance.persistence) || void 0 === t || !t.get_property(ue)),
      n = e.instance.config.capture_dead_clicks;
    return L(n) ? n : i;
  };
class wr {
  get lazyLoadedDeadClicksAutocapture() {
    return this._lazyLoadedDeadClicksAutocapture;
  }
  constructor(e, t, i) {
    this.instance = e, this.isEnabled = t, this.onCapture = i, this.startIfEnabled();
  }
  onRemoteConfig(e) {
    this.instance.persistence && this.instance.persistence.register({
      [ue]: null == e ? void 0 : e.captureDeadClicks
    }), this.startIfEnabled();
  }
  startIfEnabled() {
    this.isEnabled(this) && this.loadScript(() => {
      this.start();
    });
  }
  loadScript(e) {
    var t, i, n;
    null !== (t = m.__PosthogExtensions__) && void 0 !== t && t.initDeadClicksAutocapture && e(), null === (i = m.__PosthogExtensions__) || void 0 === i || null === (n = i.loadExternalDependency) || void 0 === n || n.call(i, this.instance, "dead-clicks-autocapture", t => {
      t ? B.error(mr + " failed to load script", t) : e();
    });
  }
  start() {
    var e;
    if (h) {
      if (!this._lazyLoadedDeadClicksAutocapture && null !== (e = m.__PosthogExtensions__) && void 0 !== e && e.initDeadClicksAutocapture) {
        var t = P(this.instance.config.capture_dead_clicks) ? this.instance.config.capture_dead_clicks : {};
        t.__onCapture = this.onCapture, this._lazyLoadedDeadClicksAutocapture = m.__PosthogExtensions__.initDeadClicksAutocapture(this.instance, t), this._lazyLoadedDeadClicksAutocapture.start(h), B.info("".concat(mr, " starting..."));
      }
    } else B.error(mr + " `document` not found. Cannot start.");
  }
  stop() {
    this._lazyLoadedDeadClicksAutocapture && (this._lazyLoadedDeadClicksAutocapture.stop(), this._lazyLoadedDeadClicksAutocapture = void 0, B.info("".concat(mr, " stopping...")));
  }
}
class Sr {
  constructor(e) {
    var t;
    i(this, "rageclicks", new fr()), i(this, "_enabledServerSide", !1), i(this, "_initialized", !1), i(this, "_flushInterval", null), this.instance = e, this._enabledServerSide = !(null === (t = this.instance.persistence) || void 0 === t || !t.props[oe]), null == o || o.addEventListener("beforeunload", () => {
      this.flush();
    });
  }
  get flushIntervalMilliseconds() {
    var e = 5e3;
    return P(this.instance.config.capture_heatmaps) && this.instance.config.capture_heatmaps.flush_interval_milliseconds && (e = this.instance.config.capture_heatmaps.flush_interval_milliseconds), e;
  }
  get isEnabled() {
    return F(this.instance.config.capture_heatmaps) ? F(this.instance.config.enable_heatmaps) ? this._enabledServerSide : this.instance.config.enable_heatmaps : !1 !== this.instance.config.capture_heatmaps;
  }
  startIfEnabled() {
    if (this.isEnabled) {
      if (this._initialized) return;
      B.info("[heatmaps] starting..."), this._setupListeners(), this._flushInterval = setInterval(this.flush.bind(this), this.flushIntervalMilliseconds);
    } else {
      var e, t;
      clearInterval(null !== (e = this._flushInterval) && void 0 !== e ? e : void 0), null === (t = this.deadClicksCapture) || void 0 === t || t.stop(), this.getAndClearBuffer();
    }
  }
  onRemoteConfig(e) {
    var t = !!e.heatmaps;
    this.instance.persistence && this.instance.persistence.register({
      [oe]: t
    }), this._enabledServerSide = t, this.startIfEnabled();
  }
  getAndClearBuffer() {
    var e = this.buffer;
    return this.buffer = void 0, e;
  }
  _onDeadClick(e) {
    this._onClick(e.originalEvent, "deadclick");
  }
  _setupListeners() {
    o && h && (ee(h, "click", e => this._onClick(e || (null == o ? void 0 : o.event)), !1, !0), ee(h, "mousemove", e => this._onMouseMove(e || (null == o ? void 0 : o.event)), !1, !0), this.deadClicksCapture = new wr(this.instance, br, this._onDeadClick.bind(this)), this.deadClicksCapture.startIfEnabled(), this._initialized = !0);
  }
  _getProperties(e, t) {
    var i = this.instance.scrollManager.scrollY(),
      n = this.instance.scrollManager.scrollX(),
      s = this.instance.scrollManager.scrollElement(),
      r = function (e, t, i) {
        for (var n = e; n && wi(n) && !Si(n, "body");) {
          if (n === i) return !1;
          if (G(t, null == o ? void 0 : o.getComputedStyle(n).position)) return !0;
          n = $i(n);
        }
        return !1;
      }(Fi(e), ["fixed", "sticky"], s);
    return {
      x: e.clientX + (r ? 0 : n),
      y: e.clientY + (r ? 0 : i),
      target_fixed: r,
      type: t
    };
  }
  _onClick(e) {
    var i,
      n = arguments.length > 1 && void 0 !== arguments[1] ? arguments[1] : "click";
    if (!yi(e.target)) {
      var s = this._getProperties(e, n);
      null !== (i = this.rageclicks) && void 0 !== i && i.isRageClick(e.clientX, e.clientY, new Date().getTime()) && this._capture(t(t({}, s), {}, {
        type: "rageclick"
      })), this._capture(s);
    }
  }
  _onMouseMove(e) {
    yi(e.target) || (clearTimeout(this._mouseMoveTimeout), this._mouseMoveTimeout = setTimeout(() => {
      this._capture(this._getProperties(e, "mousemove"));
    }, 500));
  }
  _capture(e) {
    if (o) {
      var t = o.location.href;
      this.buffer = this.buffer || {}, this.buffer[t] || (this.buffer[t] = []), this.buffer[t].push(e);
    }
  }
  flush() {
    this.buffer && !R(this.buffer) && this.instance.capture("$$heatmap", {
      $heatmap_data: this.getAndClearBuffer()
    });
  }
}
class Er {
  constructor(e) {
    i(this, "_updateScrollData", () => {
      var e, t, i, n;
      this.context || (this.context = {});
      var s = this.scrollElement(),
        r = this.scrollY(),
        o = s ? Math.max(0, s.scrollHeight - s.clientHeight) : 0,
        a = r + ((null == s ? void 0 : s.clientHeight) || 0),
        l = (null == s ? void 0 : s.scrollHeight) || 0;
      this.context.lastScrollY = Math.ceil(r), this.context.maxScrollY = Math.max(r, null !== (e = this.context.maxScrollY) && void 0 !== e ? e : 0), this.context.maxScrollHeight = Math.max(o, null !== (t = this.context.maxScrollHeight) && void 0 !== t ? t : 0), this.context.lastContentY = a, this.context.maxContentY = Math.max(a, null !== (i = this.context.maxContentY) && void 0 !== i ? i : 0), this.context.maxContentHeight = Math.max(l, null !== (n = this.context.maxContentHeight) && void 0 !== n ? n : 0);
    }), this.instance = e;
  }
  getContext() {
    return this.context;
  }
  resetContext() {
    var e = this.context;
    return setTimeout(this._updateScrollData, 0), e;
  }
  startMeasuringScrollPosition() {
    null == o || o.addEventListener("scroll", this._updateScrollData, !0), null == o || o.addEventListener("scrollend", this._updateScrollData, !0), null == o || o.addEventListener("resize", this._updateScrollData);
  }
  scrollElement() {
    if (!this.instance.config.scroll_root_selector) return null == o ? void 0 : o.document.documentElement;
    var e = I(this.instance.config.scroll_root_selector) ? this.instance.config.scroll_root_selector : [this.instance.config.scroll_root_selector];
    for (var t of e) {
      var i = null == o ? void 0 : o.document.querySelector(t);
      if (i) return i;
    }
  }
  scrollY() {
    if (this.instance.config.scroll_root_selector) {
      var e = this.scrollElement();
      return e && e.scrollTop || 0;
    }
    return o && (o.scrollY || o.pageYOffset || o.document.documentElement.scrollTop) || 0;
  }
  scrollX() {
    if (this.instance.config.scroll_root_selector) {
      var e = this.scrollElement();
      return e && e.scrollLeft || 0;
    }
    return o && (o.scrollX || o.pageXOffset || o.document.documentElement.scrollLeft) || 0;
  }
}
function kr(e, t) {
  return t.length > e ? t.slice(0, e) + "..." : t;
}
function xr(e) {
  if (e.previousElementSibling) return e.previousElementSibling;
  var t = e;
  do {
    t = t.previousSibling;
  } while (t && !wi(t));
  return t;
}
function Ir(e, t, i, n) {
  var s = e.tagName.toLowerCase(),
    r = {
      tag_name: s
    };
  Ti.indexOf(s) > -1 && !i && ("a" === s.toLowerCase() || "button" === s.toLowerCase() ? r.$el_text = kr(1024, zi(e)) : r.$el_text = kr(1024, Ri(e)));
  var o = Ci(e);
  o.length > 0 && (r.classes = o.filter(function (e) {
    return "" !== e;
  })), W(e.attributes, function (i) {
    var s;
    if ((!Ai(e) || -1 !== ["name", "id", "class", "aria-label"].indexOf(i.name)) && (null == n || !n.includes(i.name)) && !t && Ui(i.value) && (s = i.name, !T(s) || "_ngcontent" !== s.substring(0, 10) && "_nghost" !== s.substring(0, 7))) {
      var o = i.value;
      "class" === i.name && (o = xi(o).join(" ")), r["attr__" + i.name] = kr(1024, o);
    }
  });
  for (var a = 1, l = 1, u = e; u = xr(u);) a++, u.tagName === e.tagName && l++;
  return r.nth_child = a, r.nth_of_type = l, r;
}
function Cr(e, t) {
  for (var i, n, {
      e: s,
      maskAllElementAttributes: r,
      maskAllText: a,
      elementAttributeIgnoreList: l,
      elementsChainAsString: u
    } = t, c = [e], d = e; d.parentNode && !Si(d, "body");) ki(d.parentNode) ? (c.push(d.parentNode.host), d = d.parentNode.host) : (c.push(d.parentNode), d = d.parentNode);
  var h,
    _ = [],
    p = {},
    v = !1,
    g = !1;
  if (W(c, e => {
    var t = Mi(e);
    "a" === e.tagName.toLowerCase() && (v = e.getAttribute("href"), v = t && v && Ui(v) && v), G(Ci(e), "ph-no-capture") && (g = !0), _.push(Ir(e, r, a, l));
    var i = function (e) {
      if (!Mi(e)) return {};
      var t = {};
      return W(e.attributes, function (e) {
        if (e.name && 0 === e.name.indexOf("data-ph-capture-attribute")) {
          var i = e.name.replace("data-ph-capture-attribute-", ""),
            n = e.value;
          i && n && Ui(n) && (t[i] = n);
        }
      }), t;
    }(e);
    j(p, i);
  }), g) return {
    props: {},
    explicitNoCapture: g
  };
  if (a || ("a" === e.tagName.toLowerCase() || "button" === e.tagName.toLowerCase() ? _[0].$el_text = zi(e) : _[0].$el_text = Ri(e)), v) {
    var f, m;
    _[0].attr__href = v;
    var b = null === (f = dt(v)) || void 0 === f ? void 0 : f.host,
      y = null == o || null === (m = o.location) || void 0 === m ? void 0 : m.host;
    b && y && b !== y && (h = v);
  }
  return {
    props: j({
      $event_type: s.type,
      $ce_version: 1
    }, u ? {} : {
      $elements: _
    }, {
      $elements_chain: ji(_)
    }, null !== (i = _[0]) && void 0 !== i && i.$el_text ? {
      $el_text: null === (n = _[0]) || void 0 === n ? void 0 : n.$el_text
    } : {}, h && "click" === s.type ? {
      $external_click_url: h
    } : {}, p)
  };
}
class Pr {
  constructor(e) {
    i(this, "_initialized", !1), i(this, "_isDisabledServerSide", null), i(this, "rageclicks", new fr()), i(this, "_elementsChainAsString", !1), this.instance = e, this._elementSelectors = null;
  }
  get config() {
    var e,
      t,
      i = P(this.instance.config.autocapture) ? this.instance.config.autocapture : {};
    return i.url_allowlist = null === (e = i.url_allowlist) || void 0 === e ? void 0 : e.map(e => new RegExp(e)), i.url_ignorelist = null === (t = i.url_ignorelist) || void 0 === t ? void 0 : t.map(e => new RegExp(e)), i;
  }
  _addDomEventHandlers() {
    if (this.isBrowserSupported()) {
      if (o && h) {
        var e = e => {
            e = e || (null == o ? void 0 : o.event);
            try {
              this._captureEvent(e);
            } catch (e) {
              B.error("Failed to capture event", e);
            }
          },
          t = e => {
            e = e || (null == o ? void 0 : o.event), this._captureEvent(e, b);
          };
        ee(h, "submit", e, !1, !0), ee(h, "change", e, !1, !0), ee(h, "click", e, !1, !0), this.config.capture_copied_text && (ee(h, "copy", t, !1, !0), ee(h, "cut", t, !1, !0));
      }
    } else B.info("Disabling Automatic Event Collection because this browser is not supported");
  }
  startIfEnabled() {
    this.isEnabled && !this._initialized && (this._addDomEventHandlers(), this._initialized = !0);
  }
  onRemoteConfig(e) {
    e.elementsChainAsString && (this._elementsChainAsString = e.elementsChainAsString), this.instance.persistence && this.instance.persistence.register({
      [re]: !!e.autocapture_opt_out
    }), this._isDisabledServerSide = !!e.autocapture_opt_out, this.startIfEnabled();
  }
  setElementSelectors(e) {
    this._elementSelectors = e;
  }
  getElementSelectors(e) {
    var t,
      i = [];
    return null === (t = this._elementSelectors) || void 0 === t || t.forEach(t => {
      var n = null == h ? void 0 : h.querySelectorAll(t);
      null == n || n.forEach(n => {
        e === n && i.push(t);
      });
    }), i;
  }
  get isEnabled() {
    var e,
      t,
      i = null === (e = this.instance.persistence) || void 0 === e ? void 0 : e.props[re],
      n = this._isDisabledServerSide;
    if (O(n) && !L(i) && !this.instance.config.advanced_disable_decide) return !1;
    var s = null !== (t = this._isDisabledServerSide) && void 0 !== t ? t : !!i;
    return !!this.instance.config.autocapture && !s;
  }
  _captureEvent(e) {
    var t = arguments.length > 1 && void 0 !== arguments[1] ? arguments[1] : "$autocapture";
    if (this.isEnabled) {
      var i,
        n = Fi(e);
      if (Ei(n) && (n = n.parentNode || null), "$autocapture" === t && "click" === e.type && e instanceof MouseEvent) this.instance.config.rageclick && null !== (i = this.rageclicks) && void 0 !== i && i.isRageClick(e.clientX, e.clientY, new Date().getTime()) && this._captureEvent(e, "$rageclick");
      var s = t === b;
      if (n && Oi(n, e, this.config, s, s ? ["copy", "cut"] : void 0)) {
        var {
          props: r,
          explicitNoCapture: a
        } = Cr(n, {
          e: e,
          maskAllElementAttributes: this.instance.config.mask_all_element_attributes,
          maskAllText: this.instance.config.mask_all_text,
          elementAttributeIgnoreList: this.config.element_attribute_ignorelist,
          elementsChainAsString: this._elementsChainAsString
        });
        if (a) return !1;
        var l = this.getElementSelectors(n);
        if (l && l.length > 0 && (r.$element_selectors = l), t === b) {
          var u,
            c = Pi(null == o || null === (u = o.getSelection()) || void 0 === u ? void 0 : u.toString()),
            d = e.type || "clipboard";
          if (!c) return !1;
          r.$selected_content = c, r.$copy_type = d;
        }
        return this.instance.capture(t, r), !0;
      }
    }
  }
  isBrowserSupported() {
    return C(null == h ? void 0 : h.querySelectorAll);
  }
}
class Rr {
  constructor(e) {
    i(this, "_restoreXHRPatch", void 0), i(this, "_restoreFetchPatch", void 0), i(this, "_startCapturing", () => {
      var e, t, i, n;
      F(this._restoreXHRPatch) && (null === (e = m.__PosthogExtensions__) || void 0 === e || null === (t = e.tracingHeadersPatchFns) || void 0 === t || t._patchXHR(this.instance.sessionManager));
      F(this._restoreFetchPatch) && (null === (i = m.__PosthogExtensions__) || void 0 === i || null === (n = i.tracingHeadersPatchFns) || void 0 === n || n._patchFetch(this.instance.sessionManager));
    }), this.instance = e;
  }
  _loadScript(e) {
    var t, i, n;
    null !== (t = m.__PosthogExtensions__) && void 0 !== t && t.tracingHeadersPatchFns && e(), null === (i = m.__PosthogExtensions__) || void 0 === i || null === (n = i.loadExternalDependency) || void 0 === n || n.call(i, this.instance, "tracing-headers", t => {
      if (t) return B.error("[TRACING-HEADERS] failed to load script", t);
      e();
    });
  }
  startIfEnabledOrStop() {
    var e, t;
    this.instance.config.__add_tracing_headers ? this._loadScript(this._startCapturing) : (null === (e = this._restoreXHRPatch) || void 0 === e || e.call(this), null === (t = this._restoreFetchPatch) || void 0 === t || t.call(this), this._restoreXHRPatch = void 0, this._restoreFetchPatch = void 0);
  }
}
var Fr;
!function (e) {
  e[e.PENDING = -1] = "PENDING", e[e.DENIED = 0] = "DENIED", e[e.GRANTED = 1] = "GRANTED";
}(Fr || (Fr = {}));
class Tr {
  constructor(e) {
    this.instance = e;
  }
  get config() {
    return this.instance.config;
  }
  get consent() {
    return this.getDnt() ? Fr.DENIED : this.storedConsent;
  }
  isOptedOut() {
    return this.consent === Fr.DENIED || this.consent === Fr.PENDING && this.config.opt_out_capturing_by_default;
  }
  isOptedIn() {
    return !this.isOptedOut();
  }
  optInOut(e) {
    this.storage.set(this.storageKey, e ? 1 : 0, this.config.cookie_expiration, this.config.cross_subdomain_cookie, this.config.secure_cookie);
  }
  reset() {
    this.storage.remove(this.storageKey, this.config.cross_subdomain_cookie);
  }
  get storageKey() {
    var {
      token: e,
      opt_out_capturing_cookie_prefix: t
    } = this.instance.config;
    return (t || "__ph_opt_in_out_") + e;
  }
  get storedConsent() {
    var e = this.storage.get(this.storageKey);
    return "1" === e ? Fr.GRANTED : "0" === e ? Fr.DENIED : Fr.PENDING;
  }
  get storage() {
    if (!this._storage) {
      var e = this.config.opt_out_capturing_persistence_type;
      this._storage = "localStorage" === e ? nt : tt;
      var t = "localStorage" === e ? tt : nt;
      t.get(this.storageKey) && (this._storage.get(this.storageKey) || this.optInOut("1" === t.get(this.storageKey)), t.remove(this.storageKey, this.config.cross_subdomain_cookie));
    }
    return this._storage;
  }
  getDnt() {
    return !!this.config.respect_dnt && !!te([null == d ? void 0 : d.doNotTrack, null == d ? void 0 : d.msDoNotTrack, m.doNotTrack], e => G([!0, 1, "1", "yes"], e));
  }
}
var $r = "[Exception Autocapture]";
class Or {
  constructor(e) {
    var t;
    i(this, "originalOnUnhandledRejectionHandler", void 0), i(this, "startCapturing", () => {
      var e, t, i, n;
      if (o && this.isEnabled && !this.hasHandlers && !this.isCapturing) {
        var s = null === (e = m.__PosthogExtensions__) || void 0 === e || null === (t = e.errorWrappingFunctions) || void 0 === t ? void 0 : t.wrapOnError,
          r = null === (i = m.__PosthogExtensions__) || void 0 === i || null === (n = i.errorWrappingFunctions) || void 0 === n ? void 0 : n.wrapUnhandledRejection;
        if (s && r) try {
          this.unwrapOnError = s(this.captureException.bind(this)), this.unwrapUnhandledRejection = r(this.captureException.bind(this));
        } catch (e) {
          B.error($r + " failed to start", e), this.stopCapturing();
        } else B.error($r + " failed to load error wrapping functions - cannot start");
      }
    }), this.instance = e, this.remoteEnabled = !(null === (t = this.instance.persistence) || void 0 === t || !t.props[ae]), this.startIfEnabled();
  }
  get isEnabled() {
    var e;
    return null !== (e = this.remoteEnabled) && void 0 !== e && e;
  }
  get isCapturing() {
    var e;
    return !(null == o || null === (e = o.onerror) || void 0 === e || !e.__POSTHOG_INSTRUMENTED__);
  }
  get hasHandlers() {
    return this.originalOnUnhandledRejectionHandler || this.unwrapOnError;
  }
  startIfEnabled() {
    this.isEnabled && !this.isCapturing && (B.info($r + " enabled, starting..."), this.loadScript(this.startCapturing));
  }
  loadScript(e) {
    var t, i;
    this.hasHandlers && e(), null === (t = m.__PosthogExtensions__) || void 0 === t || null === (i = t.loadExternalDependency) || void 0 === i || i.call(t, this.instance, "exception-autocapture", t => {
      if (t) return B.error($r + " failed to load script", t);
      e();
    });
  }
  stopCapturing() {
    var e, t;
    null === (e = this.unwrapOnError) || void 0 === e || e.call(this), null === (t = this.unwrapUnhandledRejection) || void 0 === t || t.call(this);
  }
  onRemoteConfig(e) {
    var t = e.autocaptureExceptions;
    this.remoteEnabled = !!t || !1, this.instance.persistence && this.instance.persistence.register({
      [ae]: this.remoteEnabled
    }), this.startIfEnabled();
  }
  captureException(e) {
    var t = this.instance.requestRouter.endpointFor("ui");
    e.$exception_personURL = "".concat(t, "/project/").concat(this.instance.config.token, "/person/").concat(this.instance.get_distinct_id()), this.instance.exceptions.sendExceptionEvent(e);
  }
}
var Mr = 9e5,
  Ar = "[Web Vitals]";
class Lr {
  constructor(e) {
    var n;
    i(this, "_enabledServerSide", !1), i(this, "_initialized", !1), i(this, "buffer", {
      url: void 0,
      metrics: [],
      firstMetricTimestamp: void 0
    }), i(this, "_flushToCapture", () => {
      clearTimeout(this._delayedFlushTimer), 0 !== this.buffer.metrics.length && (this.instance.capture("$web_vitals", this.buffer.metrics.reduce((e, i) => t(t({}, e), {}, {
        ["$web_vitals_".concat(i.name, "_event")]: t({}, i),
        ["$web_vitals_".concat(i.name, "_value")]: i.value
      }), {})), this.buffer = {
        url: void 0,
        metrics: [],
        firstMetricTimestamp: void 0
      });
    }), i(this, "_addToBuffer", e => {
      var i,
        n = null === (i = this.instance.sessionManager) || void 0 === i ? void 0 : i.checkAndGetSessionAndWindowId(!0);
      if (F(n)) B.error(Ar + "Could not read session ID. Dropping metrics!");else {
        this.buffer = this.buffer || {
          url: void 0,
          metrics: [],
          firstMetricTimestamp: void 0
        };
        var s = this._currentURL();
        if (!F(s)) if (M(null == e ? void 0 : e.name) || M(null == e ? void 0 : e.value)) B.error(Ar + "Invalid metric received", e);else if (this._maxAllowedValue && e.value >= this._maxAllowedValue) B.error(Ar + "Ignoring metric with value >= " + this._maxAllowedValue, e);else this.buffer.url !== s && (this._flushToCapture(), this._delayedFlushTimer = setTimeout(this._flushToCapture, this.flushToCaptureTimeoutMs)), F(this.buffer.url) && (this.buffer.url = s), this.buffer.firstMetricTimestamp = F(this.buffer.firstMetricTimestamp) ? Date.now() : this.buffer.firstMetricTimestamp, e.attribution && e.attribution.interactionTargetElement && (e.attribution.interactionTargetElement = void 0), this.buffer.metrics.push(t(t({}, e), {}, {
          $current_url: s,
          $session_id: n.sessionId,
          $window_id: n.windowId,
          timestamp: Date.now()
        })), this.buffer.metrics.length === this.allowedMetrics.length && this._flushToCapture();
      }
    }), i(this, "_startCapturing", () => {
      var e,
        t,
        i,
        n,
        s = m.__PosthogExtensions__;
      F(s) || F(s.postHogWebVitalsCallbacks) || ({
        onLCP: e,
        onCLS: t,
        onFCP: i,
        onINP: n
      } = s.postHogWebVitalsCallbacks), e && t && i && n ? (this.allowedMetrics.indexOf("LCP") > -1 && e(this._addToBuffer.bind(this)), this.allowedMetrics.indexOf("CLS") > -1 && t(this._addToBuffer.bind(this)), this.allowedMetrics.indexOf("FCP") > -1 && i(this._addToBuffer.bind(this)), this.allowedMetrics.indexOf("INP") > -1 && n(this._addToBuffer.bind(this)), this._initialized = !0) : B.error(Ar + "web vitals callbacks not loaded - not starting");
    }), this.instance = e, this._enabledServerSide = !(null === (n = this.instance.persistence) || void 0 === n || !n.props[le]), this.startIfEnabled();
  }
  get allowedMetrics() {
    var e,
      t,
      i = P(this.instance.config.capture_performance) ? null === (e = this.instance.config.capture_performance) || void 0 === e ? void 0 : e.web_vitals_allowed_metrics : void 0;
    return F(i) ? (null === (t = this.instance.persistence) || void 0 === t ? void 0 : t.props[ce]) || ["CLS", "FCP", "INP", "LCP"] : i;
  }
  get flushToCaptureTimeoutMs() {
    return (P(this.instance.config.capture_performance) ? this.instance.config.capture_performance.web_vitals_delayed_flush_ms : void 0) || 5e3;
  }
  get _maxAllowedValue() {
    var e = P(this.instance.config.capture_performance) && A(this.instance.config.capture_performance.__web_vitals_max_value) ? this.instance.config.capture_performance.__web_vitals_max_value : Mr;
    return 0 < e && e <= 6e4 ? Mr : e;
  }
  get isEnabled() {
    var e = P(this.instance.config.capture_performance) ? this.instance.config.capture_performance.web_vitals : void 0;
    return L(e) ? e : this._enabledServerSide;
  }
  startIfEnabled() {
    this.isEnabled && !this._initialized && (B.info(Ar + " enabled, starting..."), this.loadScript(this._startCapturing));
  }
  onRemoteConfig(e) {
    var t = P(e.capturePerformance) && !!e.capturePerformance.web_vitals,
      i = P(e.capturePerformance) ? e.capturePerformance.web_vitals_allowed_metrics : void 0;
    this.instance.persistence && (this.instance.persistence.register({
      [le]: t
    }), this.instance.persistence.register({
      [ce]: i
    })), this._enabledServerSide = t, this.startIfEnabled();
  }
  loadScript(e) {
    var t, i, n;
    null !== (t = m.__PosthogExtensions__) && void 0 !== t && t.postHogWebVitalsCallbacks && e(), null === (i = m.__PosthogExtensions__) || void 0 === i || null === (n = i.loadExternalDependency) || void 0 === n || n.call(i, this.instance, "web-vitals", t => {
      t ? B.error(Ar + " failed to load script", t) : e();
    });
  }
  _currentURL() {
    var e = o ? o.location.href : void 0;
    return e || B.error(Ar + "Could not determine current URL"), e;
  }
}
var Dr = {
  icontains: (e, t) => !!o && t.href.toLowerCase().indexOf(e.toLowerCase()) > -1,
  not_icontains: (e, t) => !!o && -1 === t.href.toLowerCase().indexOf(e.toLowerCase()),
  regex: (e, t) => !!o && ht(t.href, e),
  not_regex: (e, t) => !!o && !ht(t.href, e),
  exact: (e, t) => t.href === e,
  is_not: (e, t) => t.href !== e
};
class Nr {
  constructor(e) {
    var t = this;
    i(this, "getWebExperimentsAndEvaluateDisplayLogic", function () {
      var e = arguments.length > 0 && void 0 !== arguments[0] && arguments[0];
      t.getWebExperiments(e => {
        Nr.logInfo("retrieved web experiments from the server"), t._flagToExperiments = new Map(), e.forEach(e => {
          if (e.feature_flag_key) {
            var i;
            if (t._flagToExperiments) Nr.logInfo("setting flag key ", e.feature_flag_key, " to web experiment ", e), null === (i = t._flagToExperiments) || void 0 === i || i.set(e.feature_flag_key, e);
            var n = t.instance.getFeatureFlag(e.feature_flag_key);
            T(n) && e.variants[n] && t.applyTransforms(e.name, n, e.variants[n].transforms);
          } else if (e.variants) for (var s in e.variants) {
            var r = e.variants[s];
            Nr.matchesTestVariant(r) && t.applyTransforms(e.name, s, r.transforms);
          }
        });
      }, e);
    }), this.instance = e, this.instance.onFeatureFlags(e => {
      this.onFeatureFlags(e);
    });
  }
  onFeatureFlags(e) {
    if (this._is_bot()) Nr.logInfo("Refusing to render web experiment since the viewer is a likely bot");else if (!this.instance.config.disable_web_experiments) {
      if (M(this._flagToExperiments)) return this._flagToExperiments = new Map(), this.loadIfEnabled(), void this.previewWebExperiment();
      Nr.logInfo("applying feature flags", e), e.forEach(e => {
        var t;
        if (this._flagToExperiments && null !== (t = this._flagToExperiments) && void 0 !== t && t.has(e)) {
          var i,
            n = this.instance.getFeatureFlag(e),
            s = null === (i = this._flagToExperiments) || void 0 === i ? void 0 : i.get(e);
          n && null != s && s.variants[n] && this.applyTransforms(s.name, n, s.variants[n].transforms);
        }
      });
    }
  }
  previewWebExperiment() {
    var e = Nr.getWindowLocation();
    if (null != e && e.search) {
      var t = pt(null == e ? void 0 : e.search, "__experiment_id"),
        i = pt(null == e ? void 0 : e.search, "__experiment_variant");
      t && i && (Nr.logInfo("previewing web experiments ".concat(t, " && ").concat(i)), this.getWebExperiments(e => {
        this.showPreviewWebExperiment(parseInt(t), i, e);
      }, !1, !0));
    }
  }
  loadIfEnabled() {
    this.instance.config.disable_web_experiments || this.getWebExperimentsAndEvaluateDisplayLogic();
  }
  getWebExperiments(e, t, i) {
    if (this.instance.config.disable_web_experiments && !i) return e([]);
    var n = this.instance.get_property("$web_experiments");
    if (n && !t) return e(n);
    this.instance._send_request({
      url: this.instance.requestRouter.endpointFor("api", "/api/web_experiments/?token=".concat(this.instance.config.token)),
      method: "GET",
      transport: "XHR",
      callback: t => {
        if (200 !== t.statusCode || !t.json) return e([]);
        var i = t.json.experiments || [];
        return e(i);
      }
    });
  }
  showPreviewWebExperiment(e, t, i) {
    var n = i.filter(t => t.id === e);
    n && n.length > 0 && (Nr.logInfo("Previewing web experiment [".concat(n[0].name, "] with variant [").concat(t, "]")), this.applyTransforms(n[0].name, t, n[0].variants[t].transforms, !0));
  }
  static matchesTestVariant(e) {
    return !M(e.conditions) && Nr.matchUrlConditions(e) && Nr.matchUTMConditions(e);
  }
  static matchUrlConditions(e) {
    var t;
    if (M(e.conditions) || M(null === (t = e.conditions) || void 0 === t ? void 0 : t.url)) return !0;
    var i,
      n,
      s,
      r = Nr.getWindowLocation();
    return !!r && (null === (i = e.conditions) || void 0 === i || !i.url || Dr[null !== (n = null === (s = e.conditions) || void 0 === s ? void 0 : s.urlMatchType) && void 0 !== n ? n : "icontains"](e.conditions.url, r));
  }
  static getWindowLocation() {
    return null == o ? void 0 : o.location;
  }
  static matchUTMConditions(e) {
    var t;
    if (M(e.conditions) || M(null === (t = e.conditions) || void 0 === t ? void 0 : t.utm)) return !0;
    var i = _i.campaignParams();
    if (i.utm_source) {
      var n,
        s,
        r,
        o,
        a,
        l,
        u,
        c,
        d,
        h,
        _,
        p,
        v,
        g,
        f,
        m,
        b = null === (n = e.conditions) || void 0 === n || null === (s = n.utm) || void 0 === s || !s.utm_campaign || (null === (r = e.conditions) || void 0 === r || null === (o = r.utm) || void 0 === o ? void 0 : o.utm_campaign) == i.utm_campaign,
        y = null === (a = e.conditions) || void 0 === a || null === (l = a.utm) || void 0 === l || !l.utm_source || (null === (u = e.conditions) || void 0 === u || null === (c = u.utm) || void 0 === c ? void 0 : c.utm_source) == i.utm_source,
        w = null === (d = e.conditions) || void 0 === d || null === (h = d.utm) || void 0 === h || !h.utm_medium || (null === (_ = e.conditions) || void 0 === _ || null === (p = _.utm) || void 0 === p ? void 0 : p.utm_medium) == i.utm_medium,
        S = null === (v = e.conditions) || void 0 === v || null === (g = v.utm) || void 0 === g || !g.utm_term || (null === (f = e.conditions) || void 0 === f || null === (m = f.utm) || void 0 === m ? void 0 : m.utm_term) == i.utm_term;
      return b && w && S && y;
    }
    return !1;
  }
  static logInfo(e) {
    for (var t = arguments.length, i = new Array(t > 1 ? t - 1 : 0), n = 1; n < t; n++) i[n - 1] = arguments[n];
    B.info("[WebExperiments] ".concat(e), i);
  }
  applyTransforms(e, t, i, n) {
    var s;
    this._is_bot() ? Nr.logInfo("Refusing to render web experiment since the viewer is a likely bot") : "control" !== t ? i.forEach(i => {
      if (i.selector) {
        var s;
        Nr.logInfo("applying transform of variant ".concat(t, " for experiment ").concat(e, " "), i);
        var r,
          o = 0,
          a = null === (s = document) || void 0 === s ? void 0 : s.querySelectorAll(i.selector);
        if (null == a || a.forEach(e => {
          var t = e;
          o += 1, i.attributes && i.attributes.forEach(e => {
            switch (e.name) {
              case "text":
                t.innerText = e.value;
                break;
              case "html":
                t.innerHTML = e.value;
                break;
              case "cssClass":
                t.className = e.value;
                break;
              default:
                t.setAttribute(e.name, e.value);
            }
          }), i.text && (t.innerText = i.text), i.html && (t.parentElement ? t.parentElement.innerHTML = i.html : t.innerHTML = i.html), i.css && t.setAttribute("style", i.css);
        }), this.instance && this.instance.capture) this.instance.capture("$web_experiment_applied", {
          $web_experiment_name: e,
          $web_experiment_variant: t,
          $web_experiment_preview: n,
          $web_experiment_document_url: null === (r = Nr.getWindowLocation()) || void 0 === r ? void 0 : r.href,
          $web_experiment_elements_modified: o
        });
      }
    }) : (Nr.logInfo("Control variants leave the page unmodified."), this.instance && this.instance.capture && this.instance.capture("$web_experiment_applied", {
      $web_experiment_name: e,
      $web_experiment_preview: n,
      $web_experiment_variant: t,
      $web_experiment_document_url: null === (s = Nr.getWindowLocation()) || void 0 === s ? void 0 : s.href,
      $web_experiment_elements_modified: 0
    }));
  }
  _is_bot() {
    return d && this.instance ? gr(d, this.instance.config.custom_blocked_useragents) : void 0;
  }
}
class qr {
  constructor(e) {
    this.instance = e;
  }
  sendExceptionEvent(e) {
    this.instance.capture("$exception", e, {
      _noTruncate: !0,
      _batchKey: "exceptionEvent"
    });
  }
}
var Br = ["$set_once", "$set"];
class Hr {
  constructor(e) {
    this.instance = e, this.enabled = !!this.instance.config.opt_in_site_apps && !this.instance.config.advanced_disable_decide, this.missedInvocations = [], this.loaded = !1, this.appsLoading = new Set();
  }
  eventCollector(e, t) {
    if (this.enabled && !this.loaded && t) {
      var i = this.globalsForEvent(t);
      this.missedInvocations.push(i), this.missedInvocations.length > 1e3 && (this.missedInvocations = this.missedInvocations.slice(10));
    }
  }
  init() {
    var e;
    null === (e = this.instance) || void 0 === e || e._addCaptureHook(this.eventCollector.bind(this));
  }
  globalsForEvent(e) {
    var i, s, r, o, a, l, u;
    if (!e) throw new Error("Event payload is required");
    var c = {},
      d = this.instance.get_property("$groups") || [],
      h = this.instance.get_property("$stored_group_properties") || {};
    for (var [_, p] of Object.entries(h)) c[_] = {
      id: d[_],
      type: _,
      properties: p
    };
    var {
      $set_once: v,
      $set: g
    } = e;
    return {
      event: t(t({}, n(e, Br)), {}, {
        properties: t(t(t({}, e.properties), g ? {
          $set: t(t({}, null !== (i = null === (s = e.properties) || void 0 === s ? void 0 : s.$set) && void 0 !== i ? i : {}), g)
        } : {}), v ? {
          $set_once: t(t({}, null !== (r = null === (o = e.properties) || void 0 === o ? void 0 : o.$set_once) && void 0 !== r ? r : {}), v)
        } : {}),
        elements_chain: null !== (a = null === (l = e.properties) || void 0 === l ? void 0 : l.$elements_chain) && void 0 !== a ? a : "",
        distinct_id: null === (u = e.properties) || void 0 === u ? void 0 : u.distinct_id
      }),
      person: {
        properties: this.instance.get_property("$stored_person_properties")
      },
      groups: c
    };
  }
  onRemoteConfig(e) {
    var t = this;
    I(null == e ? void 0 : e.siteApps) && e.siteApps.length > 0 ? this.enabled && this.instance.config.opt_in_site_apps ? function () {
      var i = () => {
          0 === t.appsLoading.size && (t.loaded = !0, t.missedInvocations = []);
        },
        n = function (e, n) {
          var s, r;
          t.appsLoading.add(e), m["__$$ph_site_app_".concat(e)] = t.instance, m["__$$ph_site_app_".concat(e, "_missed_invocations")] = () => t.missedInvocations, m["__$$ph_site_app_".concat(e, "_callback")] = () => {
            t.appsLoading.delete(e), i();
          }, null === (s = m.__PosthogExtensions__) || void 0 === s || null === (r = s.loadSiteApp) || void 0 === r || r.call(s, t.instance, n, n => {
            if (n) return t.appsLoading.delete(e), i(), B.error("Error while initializing PostHog app with config id ".concat(e), n);
          });
        };
      for (var {
        id: s,
        url: r
      } of e.siteApps) n(s, r);
    }() : e.siteApps.length > 0 ? (B.error('PostHog site apps are disabled. Enable the "opt_in_site_apps" config to proceed.'), this.loaded = !0) : this.loaded = !0 : (this.loaded = !0, this.enabled = !1);
  }
}
var Ur = {},
  zr = () => {},
  Wr = "posthog",
  jr = !ss && -1 === (null == f ? void 0 : f.indexOf("MSIE")) && -1 === (null == f ? void 0 : f.indexOf("Mozilla")),
  Gr = () => {
    var e, t, i;
    return {
      api_host: "https://us.i.posthog.com",
      ui_host: null,
      token: "",
      autocapture: !0,
      rageclick: !0,
      cross_subdomain_cookie: (t = null == h ? void 0 : h.location, i = null == t ? void 0 : t.hostname, !!T(i) && "herokuapp.com" !== i.split(".").slice(-2).join(".")),
      persistence: "localStorage+cookie",
      persistence_name: "",
      loaded: zr,
      store_google: !0,
      custom_campaign_params: [],
      custom_blocked_useragents: [],
      save_referrer: !0,
      capture_pageview: !0,
      capture_pageleave: "if_capture_pageview",
      debug: _ && T(null == _ ? void 0 : _.search) && -1 !== _.search.indexOf("__posthog_debug=true") || !1,
      verbose: !1,
      cookie_expiration: 365,
      upgrade: !1,
      disable_session_recording: !1,
      disable_persistence: !1,
      disable_web_experiments: !0,
      disable_surveys: !1,
      enable_recording_console_log: void 0,
      secure_cookie: "https:" === (null == o || null === (e = o.location) || void 0 === e ? void 0 : e.protocol),
      ip: !0,
      opt_out_capturing_by_default: !1,
      opt_out_persistence_by_default: !1,
      opt_out_useragent_filter: !1,
      opt_out_capturing_persistence_type: "localStorage",
      opt_out_capturing_cookie_prefix: null,
      opt_in_site_apps: !1,
      property_denylist: [],
      respect_dnt: !1,
      sanitize_properties: null,
      request_headers: {},
      inapp_protocol: "//",
      inapp_link_new_window: !1,
      request_batching: !0,
      properties_string_max_length: 65535,
      session_recording: {},
      mask_all_element_attributes: !1,
      mask_all_text: !1,
      advanced_disable_decide: !1,
      advanced_disable_feature_flags: !1,
      advanced_disable_feature_flags_on_first_load: !1,
      advanced_disable_toolbar_metrics: !1,
      feature_flag_request_timeout_ms: 3e3,
      on_request_error: e => {
        var t = "Bad HTTP status: " + e.statusCode + " " + e.text;
        B.error(t);
      },
      get_device_id: e => e,
      _onCapture: zr,
      capture_performance: void 0,
      name: "posthog",
      bootstrap: {},
      disable_compression: !1,
      session_idle_timeout_seconds: 1800,
      person_profiles: "identified_only",
      __add_tracing_headers: !1,
      before_send: void 0
    };
  },
  Vr = e => {
    var t = {};
    F(e.process_person) || (t.person_profiles = e.process_person), F(e.xhr_headers) || (t.request_headers = e.xhr_headers), F(e.cookie_name) || (t.persistence_name = e.cookie_name), F(e.disable_cookie) || (t.disable_persistence = e.disable_cookie);
    var i = j({}, t, e);
    return I(e.property_blacklist) && (F(e.property_denylist) ? i.property_denylist = e.property_blacklist : I(e.property_denylist) ? i.property_denylist = [...e.property_blacklist, ...e.property_denylist] : B.error("Invalid value for property_denylist config: " + e.property_denylist)), i;
  };
class Jr {
  constructor() {
    i(this, "__forceAllowLocalhost", !1);
  }
  get _forceAllowLocalhost() {
    return this.__forceAllowLocalhost;
  }
  set _forceAllowLocalhost(e) {
    B.error("WebPerformanceObserver is deprecated and has no impact on network capture. Use `_forceAllowLocalhostNetworkCapture` on `posthog.sessionRecording`"), this.__forceAllowLocalhost = e;
  }
}
class Qr {
  constructor() {
    i(this, "webPerformance", new Jr()), i(this, "version", r.LIB_VERSION), i(this, "_internalEventEmitter", new ks()), this.config = Gr(), this.decideEndpointWasHit = !1, this.SentryIntegration = ms, this.sentryIntegration = e => function (e, t) {
      var i = fs(e, t);
      return {
        name: gs,
        processEvent: e => i(e)
      };
    }(this, e), this.__request_queue = [], this.__loaded = !1, this.analyticsDefaultEndpoint = "/e/", this._initialPageviewCaptured = !1, this._initialPersonProfilesConfig = null, this.featureFlags = new Ue(this), this.toolbar = new is(this), this.scrollManager = new Er(this), this.pageViewManager = new Es(this), this.surveys = new cr(this), this.experiments = new Nr(this), this.exceptions = new qr(this), this.rateLimiter = new dr(this), this.requestRouter = new vs(this), this.consent = new Tr(this), this.people = {
      set: (e, t, i) => {
        var n = T(e) ? {
          [e]: t
        } : e;
        this.setPersonProperties(n), null == i || i({});
      },
      set_once: (e, t, i) => {
        var n = T(e) ? {
          [e]: t
        } : e;
        this.setPersonProperties(void 0, n), null == i || i({});
      }
    }, this.on("eventCaptured", e => B.info('send "'.concat(null == e ? void 0 : e.event, '"'), e));
  }
  init(e, t, i) {
    if (i && i !== Wr) {
      var n,
        s = null !== (n = Ur[i]) && void 0 !== n ? n : new Qr();
      return s._init(e, t, i), Ur[i] = s, Ur[Wr][i] = s, s;
    }
    return this._init(e, t, i);
  }
  _init(e) {
    var i,
      n,
      a,
      l = arguments.length > 1 && void 0 !== arguments[1] ? arguments[1] : {},
      u = arguments.length > 2 ? arguments[2] : void 0;
    if (F(e) || $(e)) return B.critical("PostHog was initialized without a token. This likely indicates a misconfiguration. Please check the first argument passed to posthog.init()"), this;
    if (this.__loaded) return B.warn("You have already initialized PostHog! Re-initializing is a no-op"), this;
    this.__loaded = !0, this.config = {}, this._triggered_notifs = [], l.person_profiles && (this._initialPersonProfilesConfig = l.person_profiles), this.set_config(j({}, Gr(), Vr(l), {
      name: u,
      token: e
    })), this.config.on_xhr_error && B.error("[posthog] on_xhr_error is deprecated. Use on_request_error instead"), this.compression = l.disable_compression ? void 0 : s.GZipJS, this.persistence = new vi(this.config), this.sessionPersistence = "sessionStorage" === this.config.persistence || "memory" === this.config.persistence ? this.persistence : new vi(t(t({}, this.config), {}, {
      persistence: "sessionStorage"
    }));
    var c = t({}, this.persistence.props),
      d = t({}, this.sessionPersistence.props);
    if (this._requestQueue = new ns(e => this._send_retriable_request(e)), this._retryQueue = new ds(this), this.__request_queue = [], this.sessionManager = new _s(this), this.sessionPropsManager = new _r(this.sessionManager, this.persistence), new Rr(this).startIfEnabledOrStop(), this.siteApps = new Hr(this), null === (i = this.siteApps) || void 0 === i || i.init(), this.sessionRecording = new Xn(this), this.sessionRecording.startIfEnabledOrStop(), this.config.disable_scroll_properties || this.scrollManager.startMeasuringScrollPosition(), this.autocapture = new Pr(this), this.autocapture.startIfEnabled(), this.surveys.loadIfEnabled(), this.heatmaps = new Sr(this), this.heatmaps.startIfEnabled(), this.webVitalsAutocapture = new Lr(this), this.exceptionObserver = new Or(this), this.exceptionObserver.startIfEnabled(), this.deadClicksAutocapture = new wr(this, yr), this.deadClicksAutocapture.startIfEnabled(), r.DEBUG = r.DEBUG || this.config.debug, r.DEBUG && B.info("Starting in debug mode", {
      this: this,
      config: l,
      thisC: t({}, this.config),
      p: c,
      s: d
    }), this._sync_opt_out_with_persistence(), void 0 !== (null === (n = l.bootstrap) || void 0 === n ? void 0 : n.distinctID)) {
      var h,
        _,
        p = this.config.get_device_id(Qe()),
        v = null !== (h = l.bootstrap) && void 0 !== h && h.isIdentifiedID ? p : l.bootstrap.distinctID;
      this.persistence.set_property(Re, null !== (_ = l.bootstrap) && void 0 !== _ && _.isIdentifiedID ? "identified" : "anonymous"), this.register({
        distinct_id: l.bootstrap.distinctID,
        $device_id: v
      });
    }
    if (this._hasBootstrappedFeatureFlags()) {
      var g,
        f,
        m = Object.keys((null === (g = l.bootstrap) || void 0 === g ? void 0 : g.featureFlags) || {}).filter(e => {
          var t, i;
          return !(null === (t = l.bootstrap) || void 0 === t || null === (i = t.featureFlags) || void 0 === i || !i[e]);
        }).reduce((e, t) => {
          var i, n;
          return e[t] = (null === (i = l.bootstrap) || void 0 === i || null === (n = i.featureFlags) || void 0 === n ? void 0 : n[t]) || !1, e;
        }, {}),
        b = Object.keys((null === (f = l.bootstrap) || void 0 === f ? void 0 : f.featureFlagPayloads) || {}).filter(e => m[e]).reduce((e, t) => {
          var i, n, s, r;
          null !== (i = l.bootstrap) && void 0 !== i && null !== (n = i.featureFlagPayloads) && void 0 !== n && n[t] && (e[t] = null === (s = l.bootstrap) || void 0 === s || null === (r = s.featureFlagPayloads) || void 0 === r ? void 0 : r[t]);
          return e;
        }, {});
      this.featureFlags.receivedFeatureFlags({
        featureFlags: m,
        featureFlagPayloads: b
      });
    }
    if (!this.get_distinct_id()) {
      var y = this.config.get_device_id(Qe());
      this.register_once({
        distinct_id: y,
        $device_id: y
      }, ""), this.persistence.set_property(Re, "anonymous");
    }
    return null == o || null === (a = o.addEventListener) || void 0 === a || a.call(o, "onpagehide" in self ? "pagehide" : "unload", this._handle_unload.bind(this)), this.toolbar.maybeLoadToolbar(), l.segment ? Ss(this, () => this._loaded()) : this._loaded(), C(this.config._onCapture) && this.config._onCapture !== zr && (B.warn("onCapture is deprecated. Please use `before_send` instead"), this.on("eventCaptured", e => this.config._onCapture(e.event, e))), this;
  }
  _onRemoteConfig(e) {
    var t, i, n, r, o, a, l, u, c;
    this.compression = void 0, e.supportedCompression && !this.config.disable_compression && (this.compression = G(e.supportedCompression, s.GZipJS) ? s.GZipJS : G(e.supportedCompression, s.Base64) ? s.Base64 : void 0), null !== (t = e.analytics) && void 0 !== t && t.endpoint && (this.analyticsDefaultEndpoint = e.analytics.endpoint), this.set_config({
      person_profiles: this._initialPersonProfilesConfig ? this._initialPersonProfilesConfig : e.defaultIdentifiedOnly ? "identified_only" : "always"
    }), null === (i = this.siteApps) || void 0 === i || i.onRemoteConfig(e), null === (n = this.sessionRecording) || void 0 === n || n.onRemoteConfig(e), null === (r = this.autocapture) || void 0 === r || r.onRemoteConfig(e), null === (o = this.heatmaps) || void 0 === o || o.onRemoteConfig(e), null === (a = this.surveys) || void 0 === a || a.onRemoteConfig(e), null === (l = this.webVitalsAutocapture) || void 0 === l || l.onRemoteConfig(e), null === (u = this.exceptionObserver) || void 0 === u || u.onRemoteConfig(e), null === (c = this.deadClicksAutocapture) || void 0 === c || c.onRemoteConfig(e);
  }
  _loaded() {
    this.config.advanced_disable_decide || this.featureFlags.setReloadingPaused(!0);
    try {
      this.config.loaded(this);
    } catch (e) {
      B.critical("`loaded` function failed", e);
    }
    this._start_queue_if_opted_in(), this.config.capture_pageview && setTimeout(() => {
      this.consent.isOptedIn() && this._captureInitialPageview();
    }, 1), new Kn(this).call();
  }
  _start_queue_if_opted_in() {
    var e;
    this.has_opted_out_capturing() || this.config.request_batching && (null === (e = this._requestQueue) || void 0 === e || e.enable());
  }
  _dom_loaded() {
    this.has_opted_out_capturing() || z(this.__request_queue, e => this._send_retriable_request(e)), this.__request_queue = [], this._start_queue_if_opted_in();
  }
  _handle_unload() {
    var e, t;
    this.config.request_batching ? (this._shouldCapturePageleave() && this.capture("$pageleave"), null === (e = this._requestQueue) || void 0 === e || e.unload(), null === (t = this._retryQueue) || void 0 === t || t.unload()) : this._shouldCapturePageleave() && this.capture("$pageleave", null, {
      transport: "sendBeacon"
    });
  }
  _send_request(e) {
    this.__loaded && (jr ? this.__request_queue.push(e) : this.rateLimiter.isServerRateLimited(e.batchKey) || (e.transport = e.transport || this.config.api_transport, e.url = os(e.url, {
      ip: this.config.ip ? 1 : 0
    }), e.headers = t({}, this.config.request_headers), e.compression = "best-available" === e.compression ? this.compression : e.compression, (e => {
      var i,
        n,
        s,
        o = t({}, e);
      o.timeout = o.timeout || 6e4, o.url = os(o.url, {
        _: new Date().getTime().toString(),
        ver: r.LIB_VERSION,
        compression: o.compression
      });
      var a = null !== (i = o.transport) && void 0 !== i ? i : "XHR",
        l = null !== (n = null === (s = te(us, e => e.transport === a)) || void 0 === s ? void 0 : s.method) && void 0 !== n ? n : us[0].method;
      if (!l) throw new Error("No available transport method");
      l(o);
    })(t(t({}, e), {}, {
      callback: t => {
        var i, n, s;
        (this.rateLimiter.checkForLimiting(t), t.statusCode >= 400) && (null === (n = (s = this.config).on_request_error) || void 0 === n || n.call(s, t));
        null === (i = e.callback) || void 0 === i || i.call(e, t);
      }
    }))));
  }
  _send_retriable_request(e) {
    this._retryQueue ? this._retryQueue.retriableRequest(e) : this._send_request(e);
  }
  _execute_array(e) {
    var t,
      i = [],
      n = [],
      s = [];
    z(e, e => {
      e && (t = e[0], I(t) ? s.push(e) : C(e) ? e.call(this) : I(e) && "alias" === t ? i.push(e) : I(e) && -1 !== t.indexOf("capture") && C(this[t]) ? s.push(e) : n.push(e));
    });
    var r = function (e, t) {
      z(e, function (e) {
        if (I(e[0])) {
          var i = t;
          W(e, function (e) {
            i = i[e[0]].apply(i, e.slice(1));
          });
        } else this[e[0]].apply(this, e.slice(1));
      }, t);
    };
    r(i, this), r(n, this), r(s, this);
  }
  _hasBootstrappedFeatureFlags() {
    var e, t;
    return (null === (e = this.config.bootstrap) || void 0 === e ? void 0 : e.featureFlags) && Object.keys(null === (t = this.config.bootstrap) || void 0 === t ? void 0 : t.featureFlags).length > 0 || !1;
  }
  push(e) {
    this._execute_array([e]);
  }
  capture(e, i, n) {
    var s;
    if (this.__loaded && this.persistence && this.sessionPersistence && this._requestQueue) {
      if (!this.consent.isOptedOut()) if (!F(e) && T(e)) {
        if (this.config.opt_out_useragent_filter || !this._is_bot()) {
          var r = null != n && n.skip_client_rate_limiting ? void 0 : this.rateLimiter.clientRateLimitContext();
          if (null == r || !r.isRateLimited) {
            this.sessionPersistence.update_search_keyword(), this.config.store_google && this.sessionPersistence.update_campaign_params(), this.config.save_referrer && this.sessionPersistence.update_referrer_info(), (this.config.store_google || this.config.save_referrer) && this.persistence.set_initial_person_info();
            var o = new Date(),
              a = (null == n ? void 0 : n.timestamp) || o,
              l = {
                uuid: Qe(),
                event: e,
                properties: this._calculate_event_properties(e, i || {}, a)
              };
            r && (l.properties.$lib_rate_limit_remaining_tokens = r.remainingTokens), (null == n ? void 0 : n.$set) && (l.$set = null == n ? void 0 : n.$set);
            var u = this._calculate_set_once_properties(null == n ? void 0 : n.$set_once);
            u && (l.$set_once = u), (l = K(l, null != n && n._noTruncate ? null : this.config.properties_string_max_length)).timestamp = a, F(null == n ? void 0 : n.timestamp) || (l.properties.$event_time_override_provided = !0, l.properties.$event_time_override_system_time = o);
            var c = t(t({}, l.properties.$set), l.$set);
            if (R(c) || this.setPersonPropertiesForFlags(c), !M(this.config.before_send)) {
              var d = this._runBeforeSend(l);
              if (!d) return;
              l = d;
            }
            this._internalEventEmitter.emit("eventCaptured", l);
            var h = {
              method: "POST",
              url: null !== (s = null == n ? void 0 : n._url) && void 0 !== s ? s : this.requestRouter.endpointFor("api", this.analyticsDefaultEndpoint),
              data: l,
              compression: "best-available",
              batchKey: null == n ? void 0 : n._batchKey
            };
            return !this.config.request_batching || n && (null == n || !n._batchKey) || null != n && n.send_instantly ? this._send_retriable_request(h) : this._requestQueue.enqueue(h), l;
          }
          B.critical("This capture call is ignored due to client rate limiting.");
        }
      } else B.error("No event name provided to posthog.capture");
    } else B.uninitializedWarning("posthog.capture");
  }
  _addCaptureHook(e) {
    return this.on("eventCaptured", t => e(t.event, t));
  }
  _calculate_event_properties(e, i, n) {
    if (n = n || new Date(), !this.persistence || !this.sessionPersistence) return i;
    var s = this.persistence.remove_event_timer(e),
      r = t({}, i);
    if (r.token = this.config.token, "$snapshot" === e) {
      var o = t(t({}, this.persistence.properties()), this.sessionPersistence.properties());
      return r.distinct_id = o.distinct_id, (!T(r.distinct_id) && !A(r.distinct_id) || $(r.distinct_id)) && B.error("Invalid distinct_id for replay event. This indicates a bug in your implementation"), r;
    }
    var a = _i.properties();
    if (this.sessionManager) {
      var {
        sessionId: l,
        windowId: u
      } = this.sessionManager.checkAndGetSessionAndWindowId();
      r.$session_id = l, r.$window_id = u;
    }
    if (this.sessionRecording && (r.$recording_status = this.sessionRecording.status), this.requestRouter.region === hs.CUSTOM && (r.$lib_custom_api_host = this.config.api_host), this.sessionPropsManager && this.config.__preview_send_client_session_params && ("$pageview" === e || "$pageleave" === e || "$autocapture" === e)) {
      var c = this.sessionPropsManager.getSessionProps();
      r = j(r, c);
    }
    if (!this.config.disable_scroll_properties) {
      var d = {};
      "$pageview" === e ? d = this.pageViewManager.doPageView(n) : "$pageleave" === e && (d = this.pageViewManager.doPageLeave(n)), r = j(r, d);
    }
    if ("$pageview" === e && h && (r.title = h.title), !F(s)) {
      var _ = n.getTime() - s;
      r.$duration = parseFloat((_ / 1e3).toFixed(3));
    }
    f && this.config.opt_out_useragent_filter && (r.$browser_type = this._is_bot() ? "bot" : "browser"), (r = j({}, a, this.persistence.properties(), this.sessionPersistence.properties(), r)).$is_identified = this._isIdentified(), I(this.config.property_denylist) ? W(this.config.property_denylist, function (e) {
      delete r[e];
    }) : B.error("Invalid value for property_denylist config: " + this.config.property_denylist + " or property_blacklist config: " + this.config.property_blacklist);
    var p = this.config.sanitize_properties;
    p && (r = p(r, e));
    var v = this._hasPersonProcessing();
    return r.$process_person_profile = v, v && this._requirePersonProcessing("_calculate_event_properties"), r;
  }
  _calculate_set_once_properties(e) {
    if (!this.persistence || !this._hasPersonProcessing()) return e;
    var t = j({}, this.persistence.get_initial_props(), e || {}),
      i = this.config.sanitize_properties;
    return i && (t = i(t, "$set_once")), R(t) ? void 0 : t;
  }
  register(e, t) {
    var i;
    null === (i = this.persistence) || void 0 === i || i.register(e, t);
  }
  register_once(e, t, i) {
    var n;
    null === (n = this.persistence) || void 0 === n || n.register_once(e, t, i);
  }
  register_for_session(e) {
    var t;
    null === (t = this.sessionPersistence) || void 0 === t || t.register(e);
  }
  unregister(e) {
    var t;
    null === (t = this.persistence) || void 0 === t || t.unregister(e);
  }
  unregister_for_session(e) {
    var t;
    null === (t = this.sessionPersistence) || void 0 === t || t.unregister(e);
  }
  _register_single(e, t) {
    this.register({
      [e]: t
    });
  }
  getFeatureFlag(e, t) {
    return this.featureFlags.getFeatureFlag(e, t);
  }
  getFeatureFlagPayload(e) {
    var t = this.featureFlags.getFeatureFlagPayload(e);
    try {
      return JSON.parse(t);
    } catch (e) {
      return t;
    }
  }
  isFeatureEnabled(e, t) {
    return this.featureFlags.isFeatureEnabled(e, t);
  }
  reloadFeatureFlags() {
    this.featureFlags.reloadFeatureFlags();
  }
  updateEarlyAccessFeatureEnrollment(e, t) {
    this.featureFlags.updateEarlyAccessFeatureEnrollment(e, t);
  }
  getEarlyAccessFeatures(e) {
    var t = arguments.length > 1 && void 0 !== arguments[1] && arguments[1];
    return this.featureFlags.getEarlyAccessFeatures(e, t);
  }
  on(e, t) {
    return this._internalEventEmitter.on(e, t);
  }
  onFeatureFlags(e) {
    return this.featureFlags.onFeatureFlags(e);
  }
  onSessionId(e) {
    var t, i;
    return null !== (t = null === (i = this.sessionManager) || void 0 === i ? void 0 : i.onSessionId(e)) && void 0 !== t ? t : () => {};
  }
  getSurveys(e) {
    var t = arguments.length > 1 && void 0 !== arguments[1] && arguments[1];
    this.surveys.getSurveys(e, t);
  }
  getActiveMatchingSurveys(e) {
    var t = arguments.length > 1 && void 0 !== arguments[1] && arguments[1];
    this.surveys.getActiveMatchingSurveys(e, t);
  }
  renderSurvey(e, t) {
    this.surveys.renderSurvey(e, t);
  }
  canRenderSurvey(e) {
    this.surveys.canRenderSurvey(e);
  }
  getNextSurveyStep(e, t, i) {
    return this.surveys.getNextSurveyStep(e, t, i);
  }
  identify(e, t, i) {
    if (!this.__loaded || !this.persistence) return B.uninitializedWarning("posthog.identify");
    if (A(e) && (e = e.toString(), B.warn("The first argument to posthog.identify was a number, but it should be a string. It has been converted to a string.")), e) {
      if (["distinct_id", "distinctid"].includes(e.toLowerCase())) B.critical('The string "'.concat(e, '" was set in posthog.identify which indicates an error. This ID should be unique to the user and not a hardcoded string.'));else if (this._requirePersonProcessing("posthog.identify")) {
        var n = this.get_distinct_id();
        if (this.register({
          $user_id: e
        }), !this.get_property("$device_id")) {
          var s = n;
          this.register_once({
            $had_persisted_distinct_id: !0,
            $device_id: s
          }, "");
        }
        e !== n && e !== this.get_property(ne) && (this.unregister(ne), this.register({
          distinct_id: e
        }));
        var r = "anonymous" === (this.persistence.get_property(Re) || "anonymous");
        e !== n && r ? (this.persistence.set_property(Re, "identified"), this.setPersonPropertiesForFlags(t || {}, !1), this.capture("$identify", {
          distinct_id: e,
          $anon_distinct_id: n
        }, {
          $set: t || {},
          $set_once: i || {}
        }), this.featureFlags.setAnonymousDistinctId(n)) : (t || i) && this.setPersonProperties(t, i), e !== n && (this.reloadFeatureFlags(), this.unregister(Pe));
      }
    } else B.error("Unique user id has not been set in posthog.identify");
  }
  setPersonProperties(e, t) {
    (e || t) && this._requirePersonProcessing("posthog.setPersonProperties") && (this.setPersonPropertiesForFlags(e || {}), this.capture("$set", {
      $set: e || {},
      $set_once: t || {}
    }));
  }
  group(e, i, n) {
    if (e && i) {
      if (this._requirePersonProcessing("posthog.group")) {
        var s = this.getGroups();
        s[e] !== i && this.resetGroupPropertiesForFlags(e), this.register({
          $groups: t(t({}, s), {}, {
            [e]: i
          })
        }), n && (this.capture("$groupidentify", {
          $group_type: e,
          $group_key: i,
          $group_set: n
        }), this.setGroupPropertiesForFlags({
          [e]: n
        })), s[e] === i || n || this.reloadFeatureFlags();
      }
    } else B.error("posthog.group requires a group type and group key");
  }
  resetGroups() {
    this.register({
      $groups: {}
    }), this.resetGroupPropertiesForFlags(), this.reloadFeatureFlags();
  }
  setPersonPropertiesForFlags(e) {
    var t = !(arguments.length > 1 && void 0 !== arguments[1]) || arguments[1];
    this._requirePersonProcessing("posthog.setPersonPropertiesForFlags") && this.featureFlags.setPersonPropertiesForFlags(e, t);
  }
  resetPersonPropertiesForFlags() {
    this.featureFlags.resetPersonPropertiesForFlags();
  }
  setGroupPropertiesForFlags(e) {
    var t = !(arguments.length > 1 && void 0 !== arguments[1]) || arguments[1];
    this._requirePersonProcessing("posthog.setGroupPropertiesForFlags") && this.featureFlags.setGroupPropertiesForFlags(e, t);
  }
  resetGroupPropertiesForFlags(e) {
    this.featureFlags.resetGroupPropertiesForFlags(e);
  }
  reset(e) {
    var t, i, n, s, r;
    if (B.info("reset"), !this.__loaded) return B.uninitializedWarning("posthog.reset");
    var o = this.get_property("$device_id");
    this.consent.reset(), null === (t = this.persistence) || void 0 === t || t.clear(), null === (i = this.sessionPersistence) || void 0 === i || i.clear(), null === (n = this.surveys) || void 0 === n || n.reset(), null === (s = this.persistence) || void 0 === s || s.set_property(Re, "anonymous"), null === (r = this.sessionManager) || void 0 === r || r.resetSessionId();
    var a = this.config.get_device_id(Qe());
    this.register_once({
      distinct_id: a,
      $device_id: e ? a : o
    }, "");
  }
  get_distinct_id() {
    return this.get_property("distinct_id");
  }
  getGroups() {
    return this.get_property("$groups") || {};
  }
  get_session_id() {
    var e, t;
    return null !== (e = null === (t = this.sessionManager) || void 0 === t ? void 0 : t.checkAndGetSessionAndWindowId(!0).sessionId) && void 0 !== e ? e : "";
  }
  get_session_replay_url(e) {
    if (!this.sessionManager) return "";
    var {
        sessionId: t,
        sessionStartTimestamp: i
      } = this.sessionManager.checkAndGetSessionAndWindowId(!0),
      n = this.requestRouter.endpointFor("ui", "/project/".concat(this.config.token, "/replay/").concat(t));
    if (null != e && e.withTimestamp && i) {
      var s,
        r = null !== (s = e.timestampLookBack) && void 0 !== s ? s : 10;
      if (!i) return n;
      var o = Math.max(Math.floor((new Date().getTime() - i) / 1e3) - r, 0);
      n += "?t=".concat(o);
    }
    return n;
  }
  alias(e, t) {
    return e === this.get_property(ie) ? (B.critical("Attempting to create alias for existing People user - aborting."), -2) : this._requirePersonProcessing("posthog.alias") ? (F(t) && (t = this.get_distinct_id()), e !== t ? (this._register_single(ne, e), this.capture("$create_alias", {
      alias: e,
      distinct_id: t
    })) : (B.warn("alias matches current distinct_id - skipping api call."), this.identify(e), -1)) : void 0;
  }
  set_config(e) {
    var i,
      n,
      s,
      o,
      a = t({}, this.config);
    P(e) && (j(this.config, Vr(e)), null === (i = this.persistence) || void 0 === i || i.update_config(this.config, a), this.sessionPersistence = "sessionStorage" === this.config.persistence || "memory" === this.config.persistence ? this.persistence : new vi(t(t({}, this.config), {}, {
      persistence: "sessionStorage"
    })), nt.is_supported() && "true" === nt.get("ph_debug") && (this.config.debug = !0), this.config.debug && (r.DEBUG = !0, B.info("set_config", {
      config: e,
      oldConfig: a,
      newConfig: t({}, this.config)
    })), null === (n = this.sessionRecording) || void 0 === n || n.startIfEnabledOrStop(), null === (s = this.autocapture) || void 0 === s || s.startIfEnabled(), null === (o = this.heatmaps) || void 0 === o || o.startIfEnabled(), this.surveys.loadIfEnabled(), this._sync_opt_out_with_persistence());
  }
  startSessionRecording(e) {
    var t = !0 === e,
      i = {
        sampling: t || !(null == e || !e.sampling),
        linked_flag: t || !(null == e || !e.linked_flag),
        url_trigger: t || !(null == e || !e.url_trigger),
        event_trigger: t || !(null == e || !e.event_trigger)
      };
    if (Object.values(i).some(Boolean)) {
      var n, s, r, o, a;
      if (null === (n = this.sessionManager) || void 0 === n || n.checkAndGetSessionAndWindowId(), i.sampling) null === (s = this.sessionRecording) || void 0 === s || s.overrideSampling();
      if (i.linked_flag) null === (r = this.sessionRecording) || void 0 === r || r.overrideLinkedFlag();
      if (i.url_trigger) null === (o = this.sessionRecording) || void 0 === o || o.overrideTrigger("url");
      if (i.event_trigger) null === (a = this.sessionRecording) || void 0 === a || a.overrideTrigger("event");
    }
    this.set_config({
      disable_session_recording: !1
    });
  }
  stopSessionRecording() {
    this.set_config({
      disable_session_recording: !0
    });
  }
  sessionRecordingStarted() {
    var e;
    return !(null === (e = this.sessionRecording) || void 0 === e || !e.started);
  }
  captureException(e, i) {
    var n,
      s = new Error("PostHog syntheticException"),
      r = C(null === (n = m.__PosthogExtensions__) || void 0 === n ? void 0 : n.parseErrorAsProperties) ? m.__PosthogExtensions__.parseErrorAsProperties([e.message, void 0, void 0, void 0, e], {
        syntheticException: s
      }) : t({
        $exception_level: "error",
        $exception_list: [{
          type: e.name,
          value: e.message,
          mechanism: {
            handled: !0,
            synthetic: !1
          }
        }]
      }, i);
    this.exceptions.sendExceptionEvent(r);
  }
  loadToolbar(e) {
    return this.toolbar.loadToolbar(e);
  }
  get_property(e) {
    var t;
    return null === (t = this.persistence) || void 0 === t ? void 0 : t.props[e];
  }
  getSessionProperty(e) {
    var t;
    return null === (t = this.sessionPersistence) || void 0 === t ? void 0 : t.props[e];
  }
  toString() {
    var e,
      t = null !== (e = this.config.name) && void 0 !== e ? e : Wr;
    return t !== Wr && (t = Wr + "." + t), t;
  }
  _isIdentified() {
    var e, t;
    return "identified" === (null === (e = this.persistence) || void 0 === e ? void 0 : e.get_property(Re)) || "identified" === (null === (t = this.sessionPersistence) || void 0 === t ? void 0 : t.get_property(Re));
  }
  _hasPersonProcessing() {
    var e, t, i, n;
    return !("never" === this.config.person_profiles || "identified_only" === this.config.person_profiles && !this._isIdentified() && R(this.getGroups()) && (null === (e = this.persistence) || void 0 === e || null === (t = e.props) || void 0 === t || !t[ne]) && (null === (i = this.persistence) || void 0 === i || null === (n = i.props) || void 0 === n || !n[Ae]));
  }
  _shouldCapturePageleave() {
    return !0 === this.config.capture_pageleave || "if_capture_pageview" === this.config.capture_pageleave && this.config.capture_pageview;
  }
  createPersonProfile() {
    this._hasPersonProcessing() || this._requirePersonProcessing("posthog.createPersonProfile") && this.setPersonProperties({}, {});
  }
  _requirePersonProcessing(e) {
    return "never" === this.config.person_profiles ? (B.error(e + ' was called, but process_person is set to "never". This call will be ignored.'), !1) : (this._register_single(Ae, !0), !0);
  }
  _sync_opt_out_with_persistence() {
    var e,
      t,
      i,
      n,
      s = this.consent.isOptedOut(),
      r = this.config.opt_out_persistence_by_default,
      o = this.config.disable_persistence || s && !!r;
    (null === (e = this.persistence) || void 0 === e ? void 0 : e.disabled) !== o && (null === (i = this.persistence) || void 0 === i || i.set_disabled(o));
    (null === (t = this.sessionPersistence) || void 0 === t ? void 0 : t.disabled) !== o && (null === (n = this.sessionPersistence) || void 0 === n || n.set_disabled(o));
  }
  opt_in_capturing(e) {
    var t;
    (this.consent.optInOut(!0), this._sync_opt_out_with_persistence(), F(null == e ? void 0 : e.captureEventName) || null != e && e.captureEventName) && this.capture(null !== (t = null == e ? void 0 : e.captureEventName) && void 0 !== t ? t : "$opt_in", null == e ? void 0 : e.captureProperties, {
      send_instantly: !0
    });
    this.config.capture_pageview && this._captureInitialPageview();
  }
  opt_out_capturing() {
    this.consent.optInOut(!1), this._sync_opt_out_with_persistence();
  }
  has_opted_in_capturing() {
    return this.consent.isOptedIn();
  }
  has_opted_out_capturing() {
    return this.consent.isOptedOut();
  }
  clear_opt_in_out_capturing() {
    this.consent.reset(), this._sync_opt_out_with_persistence();
  }
  _is_bot() {
    return d ? gr(d, this.config.custom_blocked_useragents) : void 0;
  }
  _captureInitialPageview() {
    h && !this._initialPageviewCaptured && (this._initialPageviewCaptured = !0, this.capture("$pageview", {
      title: h.title
    }, {
      send_instantly: !0
    }));
  }
  debug(e) {
    !1 === e ? (null == o || o.console.log("You've disabled debug mode."), localStorage && localStorage.removeItem("ph_debug"), this.set_config({
      debug: !1
    })) : (null == o || o.console.log("You're now in debug mode. All calls to PostHog will be logged in your console.\nYou can disable this with `posthog.debug(false)`."), localStorage && localStorage.setItem("ph_debug", "true"), this.set_config({
      debug: !0
    }));
  }
  _runBeforeSend(e) {
    if (M(this.config.before_send)) return e;
    var t = I(this.config.before_send) ? this.config.before_send : [this.config.before_send],
      i = e;
    for (var n of t) {
      if (i = n(i), M(i)) {
        var s = "Event '".concat(e.event, "' was rejected in beforeSend function");
        return N(e.event) ? B.warn("".concat(s, ". This can cause unexpected behavior.")) : B.info(s), null;
      }
      i.properties && !R(i.properties) || B.warn("Event '".concat(e.event, "' has no properties after beforeSend function, this is likely an error."));
    }
    return i;
  }
}
exports.PostHog = Qr;
!function (e, t) {
  for (var i = 0; i < t.length; i++) e.prototype[t[i]] = Q(e.prototype[t[i]]);
}(Qr, ["identify"]);
var Yr,
  Xr = exports.posthog = exports.default = (Yr = Ur[Wr] = new Qr(), function () {
    function e() {
      e.done || (e.done = !0, jr = !1, W(Ur, function (e) {
        e._dom_loaded();
      }));
    }
    null != h && h.addEventListener && ("complete" === h.readyState ? e() : h.addEventListener("DOMContentLoaded", e, !1)), o && ee(o, "load", e, !0);
  }(), Yr);

},{}]},{},[1])(1)
});


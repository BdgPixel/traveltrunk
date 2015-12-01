/*
 * jQuery Plugin: Tokenizing Autocomplete Text Entry
 * Version 1.6.0
 *
 * Copyright (c) 2009 James Smith (http://loopj.com)
 * Licensed jointly under the GPL and MIT licenses,
 * choose which one suits your project best!
 *
 */
!function(e){var t={method:"GET",contentType:"json",queryParam:"q",searchDelay:300,minChars:1,propertyToSearch:"name",jsonContainer:null,hintText:"Type in a search term",noResultsText:"No results",searchingText:"Searching...",deleteText:"&times;",animateDropdown:!0,tokenLimit:null,tokenDelimiter:",",preventDuplicates:!1,tokenValue:"id",prePopulate:null,processPrePopulate:!1,idPrefix:"token-input-",resultsFormatter:function(e){return"<li>"+e[this.propertyToSearch]+"</li>"},tokenFormatter:function(e){return"<li><p>"+e[this.propertyToSearch]+"</p></li>"},onResult:null,onAdd:null,onDelete:null,onReady:null},n={tokenList:"token-input-list",token:"token-input-token",tokenDelete:"token-input-delete-token",selectedToken:"token-input-selected-token",highlightedToken:"token-input-highlighted-token",dropdown:"token-input-dropdown",dropdownItem:"token-input-dropdown-item",dropdownItem2:"token-input-dropdown-item2",selectedDropdownItem:"token-input-selected-dropdown-item",inputToken:"token-input-input-token"},o={BEFORE:0,AFTER:1,END:2},i={BACKSPACE:8,TAB:9,ENTER:13,ESCAPE:27,SPACE:32,PAGE_UP:33,PAGE_DOWN:34,END:35,HOME:36,LEFT:37,UP:38,RIGHT:39,DOWN:40,NUMPAD_ENTER:108,COMMA:188},a={init:function(n,o){var i=e.extend({},t,o||{});return this.each(function(){e(this).data("tokenInputObject",new e.TokenList(this,n,i))})},clear:function(){return this.data("tokenInputObject").clear(),this},add:function(e){return this.data("tokenInputObject").add(e),this},remove:function(e){return this.data("tokenInputObject").remove(e),this},get:function(){return this.data("tokenInputObject").getTokens()}};e.fn.tokenInput=function(e){return a[e]?a[e].apply(this,Array.prototype.slice.call(arguments,1)):a.init.apply(this,arguments)},e.TokenList=function(t,a,s){function r(){return null!==s.tokenLimit&&F>=s.tokenLimit?(O.hide(),void g()):void 0}function l(){if(L!==(L=O.val())){var e=L.replace(/&/g,"&amp;").replace(/\s/g," ").replace(/</g,"&lt;").replace(/>/g,"&gt;");U.html(e),O.width(U.width()+30)}}function c(t){var n=s.tokenFormatter(t);n=e(n).addClass(s.classes.token).insertBefore(G),e("<span>"+s.deleteText+"</span>").addClass(s.classes.tokenDelete).appendTo(n).click(function(){return h(e(this).parent()),j.change(),!1});var o={id:t.id};return o[s.propertyToSearch]=t[s.propertyToSearch],e.data(n.get(0),"tokeninput",t),A=A.slice(0,I).concat([o]).concat(A.slice(I)),I++,m(A,j),F+=1,null!==s.tokenLimit&&F>=s.tokenLimit&&(O.hide(),g()),n}function u(t){var n=s.onAdd;if(F>0&&s.preventDuplicates){var o=null;if($.children().each(function(){var n=e(this),i=e.data(n.get(0),"tokeninput");return i&&i.id===t.id?(o=n,!1):void 0}),o)return d(o),G.insertAfter(o),void O.focus()}(null==s.tokenLimit||F<s.tokenLimit)&&(c(t),r()),O.val(""),g(),e.isFunction(n)&&n.call(j,t)}function d(e){e.addClass(s.classes.selectedToken),N=e.get(0),O.val(""),g()}function p(e,t){e.removeClass(s.classes.selectedToken),N=null,t===o.BEFORE?(G.insertBefore(e),I--):t===o.AFTER?(G.insertAfter(e),I++):(G.appendTo($),I=F),O.focus()}function f(t){var n=N;N&&p(e(N),o.END),n===t.get(0)?p(t,o.END):d(t)}function h(t){var n=e.data(t.get(0),"tokeninput"),o=s.onDelete,i=t.prevAll().length;i>I&&i--,t.remove(),N=null,O.focus(),A=A.slice(0,i).concat(A.slice(i+1)),I>i&&I--,m(A,j),F-=1,null!==s.tokenLimit&&O.show().val("").focus(),e.isFunction(o)&&o.call(j,n)}function m(t,n){var o=e.map(t,function(e){return e[s.tokenValue]});n.val(o.join(s.tokenDelimiter))}function g(){M.hide().empty(),B=null}function k(){M.css({position:"absolute",top:e($).offset().top+e($).outerHeight(),left:e($).offset().left,zindex:999}).show()}function v(){s.searchingText&&(M.html("<p>"+s.searchingText+"</p>"),k())}function T(){s.hintText&&(M.html("<p>"+s.hintText+"</p>"),k())}function b(e,t){return e.replace(new RegExp("(?![^&;]+;)(?!<[^<>]*)("+t+")(?![^<>]*>)(?![^&;]+;)","gi"),"<b>$1</b>")}function y(e,t,n){return e.replace(new RegExp("(?![^&;]+;)(?!<[^<>]*)("+t+")(?![^<>]*>)(?![^&;]+;)","g"),b(t,n))}function w(t,n){if(n&&n.length){M.empty();var o=e("<ul>").appendTo(M).mouseover(function(t){C(e(t.target).closest("li"))}).mousedown(function(t){return u(e(t.target).closest("li").data("tokeninput")),j.change(),!1}).hide();e.each(n,function(n,i){var a=s.resultsFormatter(i);a=y(a,i[s.propertyToSearch],t),a=e(a).appendTo(o),n%2?a.addClass(s.classes.dropdownItem):a.addClass(s.classes.dropdownItem2),0===n&&C(a),e.data(a.get(0),"tokeninput",i)}),k(),s.animateDropdown?o.slideDown("fast"):o.show()}else s.noResultsText&&(M.html("<p>"+s.noResultsText+"</p>"),k())}function C(t){t&&(B&&_(e(B)),t.addClass(s.classes.selectedDropdownItem),B=t.get(0))}function _(e){e.removeClass(s.classes.selectedDropdownItem),B=null}function E(){var t=O.val().toLowerCase();t&&t.length&&(N&&p(e(N),o.AFTER),t.length>=s.minChars?(v(),clearTimeout(P),P=setTimeout(function(){D(t)},s.searchDelay)):g())}function D(t){var n=t+R(),o=S.get(n);if(o)w(t,o);else if(s.url){var i=R(),a={};if(a.data={},i.indexOf("?")>-1){var r=i.split("?");a.url=r[0];var l=r[1].split("&");e.each(l,function(e,t){var n=t.split("=");a.data[n[0]]=n[1]})}else a.url=i;a.data[s.queryParam]=t,a.type=s.method,a.dataType=s.contentType,s.crossDomain&&(a.dataType="jsonp"),a.success=function(o){e.isFunction(s.onResult)&&(o=s.onResult.call(j,o)),S.add(n,s.jsonContainer?o[s.jsonContainer]:o),O.val().toLowerCase()===t&&w(t,s.jsonContainer?o[s.jsonContainer]:o)},e.ajax(a)}else if(s.local_data){var c=e.grep(s.local_data,function(e){return e[s.propertyToSearch].toLowerCase().indexOf(t.toLowerCase())>-1});e.isFunction(s.onResult)&&(c=s.onResult.call(j,c)),S.add(n,c),w(t,c)}}function R(){var e=s.url;return"function"==typeof s.url&&(e=s.url.call()),e}if("string"===e.type(a)||"function"===e.type(a)){s.url=a;var x=R();void 0===s.crossDomain&&(-1===x.indexOf("://")?s.crossDomain=!1:s.crossDomain=location.href.split(/\/+/g)[1]!==x.split(/\/+/g)[1])}else"object"==typeof a&&(s.local_data=a);s.classes?s.classes=e.extend({},n,s.classes):s.theme?(s.classes={},e.each(n,function(e,t){s.classes[e]=t+"-"+s.theme})):s.classes=n;var P,L,A=[],F=0,S=new e.TokenList.Cache,O=e('<input type="text"  autocomplete="off">').css({outline:"none"}).attr("id",s.idPrefix+t.id).focus(function(){(null===s.tokenLimit||s.tokenLimit!==F)&&T()}).blur(function(){g(),e(this).val("")}).bind("keyup keydown blur update",l).keydown(function(t){var n,a;switch(t.keyCode){case i.LEFT:case i.RIGHT:case i.UP:case i.DOWN:if(e(this).val()){var s=null;return s=t.keyCode===i.DOWN||t.keyCode===i.RIGHT?e(B).next():e(B).prev(),s.length&&C(s),!1}n=G.prev(),a=G.next(),n.length&&n.get(0)===N||a.length&&a.get(0)===N?t.keyCode===i.LEFT||t.keyCode===i.UP?p(e(N),o.BEFORE):p(e(N),o.AFTER):t.keyCode!==i.LEFT&&t.keyCode!==i.UP||!n.length?t.keyCode!==i.RIGHT&&t.keyCode!==i.DOWN||!a.length||d(e(a.get(0))):d(e(n.get(0)));break;case i.BACKSPACE:if(n=G.prev(),!e(this).val().length)return N?(h(e(N)),j.change()):n.length&&d(e(n.get(0))),!1;1===e(this).val().length?g():setTimeout(function(){E()},5);break;case i.TAB:case i.ENTER:case i.NUMPAD_ENTER:case i.COMMA:if(B)return u(e(B).data("tokeninput")),j.change(),!1;break;case i.ESCAPE:return g(),!0;default:String.fromCharCode(t.which)&&setTimeout(function(){E()},5)}}),j=e(t).hide().val("").focus(function(){O.focus()}).blur(function(){O.blur()}),N=null,I=0,B=null,$=e("<ul />").addClass(s.classes.tokenList).click(function(t){var n=e(t.target).closest("li");n&&n.get(0)&&e.data(n.get(0),"tokeninput")?f(n):(N&&p(e(N),o.END),O.focus())}).mouseover(function(t){var n=e(t.target).closest("li");n&&N!==this&&n.addClass(s.classes.highlightedToken)}).mouseout(function(t){var n=e(t.target).closest("li");n&&N!==this&&n.removeClass(s.classes.highlightedToken)}).insertBefore(j),G=e("<li />").addClass(s.classes.inputToken).appendTo($).append(O),M=e("<div>").addClass(s.classes.dropdown).appendTo("body").hide(),U=e("<tester/>").insertAfter(O).css({position:"absolute",top:-9999,left:-9999,width:"auto",fontSize:O.css("fontSize"),fontFamily:O.css("fontFamily"),fontWeight:O.css("fontWeight"),letterSpacing:O.css("letterSpacing"),whiteSpace:"nowrap"});j.val("");var W=s.prePopulate||j.data("pre");s.processPrePopulate&&e.isFunction(s.onResult)&&(W=s.onResult.call(j,W)),W&&W.length&&e.each(W,function(e,t){c(t),r()}),e.isFunction(s.onReady)&&s.onReady.call(),this.clear=function(){$.children("li").each(function(){0===e(this).children("input").length&&h(e(this))})},this.add=function(e){u(e)},this.remove=function(t){$.children("li").each(function(){if(0===e(this).children("input").length){var n=e(this).data("tokeninput"),o=!0;for(var i in t)if(t[i]!==n[i]){o=!1;break}o&&h(e(this))}})},this.getTokens=function(){return A}},e.TokenList.Cache=function(t){var n=e.extend({max_size:500},t),o={},i=0,a=function(){o={},i=0};this.add=function(e,t){i>n.max_size&&a(),o[e]||(i+=1),o[e]=t},this.get=function(e){return o[e]}}}(jQuery),function(){var e;e=function(){$("#invitationForm").validate({ignore:".ignore",rules:{autocomplete:"required"},messages:{autocomplete:"Please enter your email invitation"}})},$(document).ready(function(){return e(),$("#invite_user_id").tokenInput("/group/users_collection.json",{allowCustomEntry:!0,preventDuplicates:!1,prePopulate:$("#invite_user_id").data("load")}),$("#slideToggleLink").click(function(){return $("#slideToggle").slideToggle()})})}.call(this);
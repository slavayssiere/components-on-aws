(window.webpackJsonp=window.webpackJsonp||[]).push([[8],{207:function(e,n,t){"use strict";t.r(n);var a=t(0),s=Object(a.a)({},(function(){var e=this,n=e.$createElement,t=e._self._c||n;return t("ContentSlotsDistributor",{attrs:{"slot-key":e.$parent.slotKey}},[t("h1",{attrs:{id:"explication"}},[t("a",{staticClass:"header-anchor",attrs:{href:"#explication"}},[e._v("#")]),e._v(" Explication")]),e._v(" "),t("p",[e._v("L'approche composant permet de mettre à disposition aux différentes équipes de développement des éléments d'infrastructure facilement instanciables et approvés.")]),e._v(" "),t("p",[e._v("Lors de la création d'une plateforme l'utilisateur créera un fichier permettant l'assemblage de ces éléments.")]),e._v(" "),t("p",[e._v("Un document exemple de ce manifest de création de plateform.")]),e._v(" "),t("div",{staticClass:"language-language-yaml extra-class"},[t("pre",{pre:!0,attrs:{class:"language-text"}},[t("code",[e._v("name: $plateform\ntype: (prd || oat || dev)\ncomponent-base:\n  enabled: true\n  some: other\ncomponent-network:\n  enabled: true\n  cidr-vpc: 10.1.0.0/16\n  some: other\ncomponent-k8s:\n  enabled: true\n  cidr-calico: 10.2.0.0/16\napplications:\n  - component-project-a:\n      enabled: true\n  - component-project-b:\n      enabled: true\n      some: key\n      some: value\n...\n")])])]),t("p",[e._v("NOTES:")]),e._v(" "),t("ul",[t("li",[e._v("s'il n'est pas dans la liste un composant n'est pas instancié")]),e._v(" "),t("li",[e._v("gestion des dépendances: TODO")])])])}),[],!1,null,null,null);n.default=s.exports}}]);
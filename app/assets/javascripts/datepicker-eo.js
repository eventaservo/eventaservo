/* Esperanto initialisation for the jQuery UI date picker plugin. */
/* Written by Olivier M. (olivierweb@ifrance.com). */
( function( factory ) {
    if ( typeof define === "function" && define.amd ) {

        // AMD. Register as an anonymous module.
        define( [ "../widgets/datepicker" ], factory );
    } else {

        // Browser globals
        factory( jQuery.datepicker );
    }
}( function( datepicker ) {

    datepicker.regional.eo = {
        closeText: "Fermi",
        prevText: "&#x3C;Anta",
        nextText: "Sekv&#x3E;",
        currentText: "Nuna",
        monthNames: [ "januaro","februaro","marto","aprilo","majo","junio",
            "julio","aŭgusto","septembro","oktobro","novembro","decembro" ],
        monthNamesshort: [ "jan","feb","mar","apr","maj","jun",
            "jul","aŭg","sep","okt","nov","dec" ],
        dayNames: [ "dimanĉo","Lundo","mardo","merkredo","ĵaŭdo","vendredo","sabato" ],
        dayNamesShort: [ "dim","lun","mar","mer","ĵaŭ","ven","sab" ],
        dayNamesMin: [ "di","lu","ma","me","ĵa","ve","sa" ],
        weekHeader: "Sb",
        dateFormat: "dd/mm/yy",
        firstDay: 0,
        isRTL: false,
        showMonthAfterYear: false,
        yearSuffix: "" };
    datepicker.setDefaults( datepicker.regional.eo );

    return datepicker.regional.eo;

} ) );
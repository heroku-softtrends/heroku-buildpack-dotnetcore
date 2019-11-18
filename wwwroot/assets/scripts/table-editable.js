var TableEditable = function () {

    return {

        //main function to initiate the module
        init: function () {
            $('table[id^=sample_editable]').each(function () {
              
                if ($(this).find('tbody tr').length > 1) {
                    var maxcol = $(this).find('thead th').length - 1;
                   // alert(maxcol);
                    var settings = {};
                    if ($($(this).find('thead th')[maxcol]).hasClass("sorting-disabled")) {
                        settings = {
                            "aoColumnDefs": [
                                 { "bSortable": false, "aTargets": [maxcol] }
                            ],
                            "aLengthMenu": [
                                [5, 15, 20, -1],
                                [5, 15, 20, "All"] // change per page values here
                            ],
                            // set the initial value
                            "iDisplayLength": 5,

                            "sPaginationType": "bootstrap",
                            "oLanguage": {
                                "sLengthMenu": "_MENU_ records",
                                "oPaginate": {
                                    "sPrevious": "Prev",
                                    "sNext": "Next"
                                }
                            }
                        };
                    }
                    else {
                       
                        settings = {
                            "aLengthMenu": [
                                [5, 15, 20, -1],
                                [5, 15, 20, "All"] // change per page values here
                            ],
                            // set the initial value
                            "iDisplayLength": 5,

                            "sPaginationType": "bootstrap",
                            "oLanguage": {
                                "sLengthMenu": "_MENU_ records",
                                "oPaginate": {
                                    "sPrevious": "Prev",
                                    "sNext": "Next"
                                }
                            }
                        };
                    }

                   
                    var oTable = $(this).dataTable(settings);

                    jQuery('#' + $(this).attr('id') + '_wrapper .dataTables_filter input').addClass("form-control input-medium input-inline"); // modify table search input
                    jQuery('#' + $(this).attr('id') + '_wrapper .dataTables_length select').addClass("form-control input-small"); // modify table per page dropdown
                    //jQuery('#' + $(this).attr('id') + '_wrapper .dataTables_length select').select2({
                    //    showSearchInput: false //hide search box with special css class
                    //});
                }
            });

            //var oTable = $('#sample_editable_1').dataTable({
            //    "aLengthMenu": [
            //        [5, 15, 20, -1],
            //        [5, 15, 20, "All"] // change per page values here
            //    ],
            //    // set the initial value
            //    "iDisplayLength": 5,

            //    "sPaginationType": "bootstrap",
            //    "oLanguage": {
            //        "sLengthMenu": "_MENU_ records",
            //        "oPaginate": {
            //            "sPrevious": "Prev",
            //            "sNext": "Next"
            //        }
            //    }

            //});

            //jQuery('#sample_editable_1_wrapper .dataTables_filter input').addClass("form-control input-medium input-inline"); // modify table search input
            //jQuery('#sample_editable_1_wrapper .dataTables_length select').addClass("form-control input-small"); // modify table per page dropdown
            //jQuery('#sample_editable_1_wrapper .dataTables_length select').select2({
            //    showSearchInput: false //hide search box with special css class
            //}); // initialize select2 dropdown

            // var nEditing = null;

        }

    };

}();
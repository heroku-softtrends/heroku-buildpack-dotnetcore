var ComponentsPickers = function () {

    var handleDatePickers = function () {

        if (jQuery().datepicker) {
            $('.date-picker').datepicker({
                rtl: App.isRTL(),
                autoclose: true
            });
            $('body').removeClass("modal-open"); // fix bug when inline picker is used in modal
        }
    }

    var handleTimePickers = function () {

        if (jQuery().timepicker) {
            $('.timepicker-default').timepicker({
                autoclose: true,
                showSeconds: true,
                minuteStep: 1
            });

            $('.timepicker-no-seconds').timepicker({
                autoclose: true,
                minuteStep: 5
            });

            $('.timepicker-24').timepicker({
                autoclose: true,
                minuteStep: 5,
                showSeconds: true,
                showMeridian: false
            });

            // handle input group button click
            $('.timepicker').parent('.input-group').on('click', '.input-group-btn', function (e) {
                e.preventDefault();
                $(this).parent('.input-group').find('.timepicker').timepicker('showWidget');
            });
        }
    }

    var handleDateRangePickers = function () {
        if (!jQuery().daterangepicker) {
            return;
        }

        $('#defaultrange').daterangepicker({
            opens: (App.isRTL() ? 'left' : 'left'),
            format: 'MM/DD/YYYY',
            separator: ' to ',
            startDate: moment().subtract('days', 29),
            endDate: moment(),
            minDate: '01/01/2012',
            maxDate: '12/31/2020',
        },
            function (start, end) {
                console.log("Callback has been called!");
                $('#defaultrange input').val(start.format('MMMM D, YYYY') + ' - ' + end.format('MMMM D, YYYY'));
            }
        );

        $('#defaultrange_modal').daterangepicker({
            opens: (App.isRTL() ? 'left' : 'left'),
            format: 'MM/DD/YYYY',
            separator: ' to ',
            startDate: moment().subtract('days', 29),
            endDate: moment(),
            minDate: '01/01/2012',
            maxDate: '12/31/2020',
        },
            function (start, end) {
                $('#defaultrange_modal input').val(start.format('MMMM D, YYYY') + ' - ' + end.format('MMMM D, YYYY'));
            }
        );

        // this is very important fix when daterangepicker is used in modal. in modal when daterange picker is opened and mouse clicked anywhere bootstrap modal removes the modal-open class from the body element.
        // so the below code will fix this issue.
        $('#defaultrange_modal').on('click', function () {
            if ($('#daterangepicker_modal').is(":visible") && $('body').hasClass("modal-open") == false) {
                $('body').addClass("modal-open");
            }
        });

        $('#reportrange').daterangepicker({
            opens: (App.isRTL() ? 'left' : 'left'),
            startDate: moment().subtract('days', 29),
            endDate: moment(),
            minDate: '01/01/2012',
            maxDate: '12/31/2020',
            dateLimit: {
                days: 240
            },
            showDropdowns: true,
            showWeekNumbers: true,
            timePicker: false,
            timePickerIncrement: 1,
            timePicker12Hour: true,
            ranges: {
                'Today': [moment(), moment()],
                'Yesterday': [moment().subtract('days', 1), moment().subtract('days', 1)],
                'Last 7 Days': [moment().subtract('days', 6), moment()],
                'Last 30 Days': [moment().subtract('days', 30), moment()],
                'This Month': [moment().startOf('month'), moment().endOf('month')],
                'Last Month': [moment().subtract('month', 1).startOf('month'), moment().subtract('month', 1).endOf('month')]

            },
            buttonClasses: ['btn'],
            applyClass: 'green',
            cancelClass: 'default',
            format: 'MM/DD/YYYY',
            separator: ' to ',
            locale: {
                applyLabel: 'Apply',
                fromLabel: 'From',
                toLabel: 'To',
                customRangeLabel: 'Custom Range',
                daysOfWeek: ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'],
                monthNames: ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'],
                firstDay: 1
            }
        },
            function (start, end) {
                //console.log("Callback has been called!");

                //alert(daysBetween(new Date(start), new Date(end)));
                switch (daysBetween(new Date(start), new Date(end))) {
                    case 0:
                        //alert('End Date: ' + new Date(end));
                        //alert('Today Date: ' + new Date());
                        //alert(new Date().getDate() + "$" + new Date(end).getDate());
                        if (new Date().getDate() == new Date(end).getDate())
                            $('#reportrange span').html('Today');
                        else
                            $('#reportrange span').html('Yesterday');
                        break;
                    case 6:
                        $('#reportrange span').html('Last 7 Days');
                        break;
                    case 29:
                        $('#reportrange span').html('Last Month');
                        break;
                    case 30:
                        if (new Date().getDate() == new Date(end).getDate())
                            $('#reportrange span').html('Last 30 Days');
                        else
                            $('#reportrange span').html('This Month');
                        break;
                    default: $('#reportrange span').html(start.format('MMMM D, YYYY') + ' - ' + end.format('MMMM D, YYYY'));
                        break;
                }
                // alert(new Date(start).getTime());
                //$('#reportrange span').html(start.format('MMMM D, YYYY') + ' - ' + end.format('MMMM D, YYYY'));
                if ($('#reportrange span').attr("data-name") == undefined || $('#reportrange span').attr("data-name") == false || $('#reportrange span').attr("data-name") == null) {
                    ControllerCall($('#reportrange span').attr("id"), start.format('DD-MM-YYYY'), end.format('DD-MM-YYYY'));
                }
                else {
                    ControllerCallWithName($('#reportrange span').attr("id"), $('#reportrange span').attr("data-name"), start.format('DD-MM-YYYY'), end.format('DD-MM-YYYY'));
                }

            }
        );
        //Set the initial state of the picker label
        $('#reportrange span').html(moment().subtract('days', 29).format('MMMM D, YYYY') + ' - ' + moment().format('MMMM D, YYYY'));
    }

    var ControllerCall = function (controllername, fromdate, todate) {
        //alert('calling without name');
        // alert(controllername);

        if (controllername == "StoreVisit") {
            var id = "";
            if ($('#bredcrumbend').text() != undefined && $('#bredcrumbend').text() != "") {
                id = $('#bredcrumbend').text();
            }
            $("#myIframe").attr('src', '/images/ajax-loader.gif')
            window.location.href = "/" + controllername + "/Index/" + id + "?FromDate=" + fromdate + "&ToDate=" + todate + "&Date=" + $('#reportrange span').html();
            $("#myIframe").attr('src', '/images/ajax-loader.gif')
        }
        else {
            $("#myIframe").attr('src', '/images/ajax-loader.gif')
            window.location.href = "/" + controllername + "/Index?FromDate=" + fromdate + "&ToDate=" + todate + "&Date=" + $('#reportrange span').html();
            $("#myIframe").attr('src', '/images/ajax-loader.gif')
        }


    };
    var ControllerCallWithName = function (controllername, name, fromdate, todate) {
        // alert('calling with name
        if (controllername == "StoreVisit") {
            var id = "";
            if ($('#bredcrumbend').text() != undefined && $('#bredcrumbend').text() != "") {
                id = $('#bredcrumbend').text();
            }
            $("#myIframe").attr('src', '/images/ajax-loader.gif')
            window.location.href = "/" + controllername + "/Index/" + id + "?FromDate=" + fromdate + "&ToDate=" + todate + "&Date=" + $('#reportrange span').html() + "&assigneduserguid=" + name;
            $("#myIframe").attr('src', '/images/ajax-loader.gif')
        }
        else {
            $("#myIframe").attr('src', '/images/ajax-loader.gif')
            window.location.href = "/" + controllername + "/Index?FromDate=" + fromdate + "&ToDate=" + todate + "&Date=" + $('#reportrange span').html() + "&assigneduserguid=" + name;
            $("#myIframe").attr('src', '/images/ajax-loader.gif')
        }

    };

    daysBetween = function (date1, date2) {
        //Get 1 day in milliseconds
        var one_day = 1000 * 60 * 60 * 24;

        // Convert both dates to milliseconds
        var date1_ms = date1.getTime();
        var date2_ms = date2.getTime();

        // Calculate the difference in milliseconds
        var difference_ms = date2_ms - date1_ms;

        // Convert back to days and return
        return Math.round(difference_ms / one_day);
    }

    var handleDatetimePicker = function () {

        $(".form_datetime").datetimepicker({
            autoclose: true,
            isRTL: App.isRTL(),
            format: "dd MM yyyy - hh:ii",
            pickerPosition: (App.isRTL() ? "bottom-right" : "bottom-left")
        });

        $(".form_advance_datetime").datetimepicker({
            isRTL: App.isRTL(),
            format: "dd MM yyyy - hh:ii",
            autoclose: true,
            todayBtn: true,
            startDate: "2013-02-14 10:00",
            pickerPosition: (App.isRTL() ? "bottom-right" : "bottom-left"),
            minuteStep: 10
        });

        $(".form_meridian_datetime").datetimepicker({
            isRTL: App.isRTL(),
            format: "dd MM yyyy - HH:ii P",
            showMeridian: true,
            autoclose: true,
            pickerPosition: (App.isRTL() ? "bottom-right" : "bottom-left"),
            todayBtn: true
        });

        $('body').removeClass("modal-open"); // fix bug when inline picker is used in modal
    }

    var handleClockfaceTimePickers = function () {

        if (!jQuery().clockface) {
            return;
        }

        $('.clockface_1').clockface();

        $('#clockface_2').clockface({
            format: 'HH:mm',
            trigger: 'manual'
        });

        $('#clockface_2_toggle').click(function (e) {
            e.stopPropagation();
            $('#clockface_2').clockface('toggle');
        });

        $('#clockface_2_modal').clockface({
            format: 'HH:mm',
            trigger: 'manual'
        });

        $('#clockface_2_modal_toggle').click(function (e) {
            e.stopPropagation();
            $('#clockface_2_modal').clockface('toggle');
        });

        $('.clockface_3').clockface({
            format: 'H:mm'
        }).clockface('show', '14:30');
    }

    var handleColorPicker = function () {
        if (!jQuery().colorpicker) {
            return;
        }
        $('.colorpicker-default').colorpicker({
            format: 'hex'
        });
        $('.colorpicker-rgba').colorpicker();
    }


    return {
        //main function to initiate the module
        init: function () {
            // handleDatePickers();
            // handleTimePickers();
            // handleDatetimePicker();
            handleDateRangePickers();
            //  handleClockfaceTimePickers();
            // handleColorPicker();
        }
    };

}();
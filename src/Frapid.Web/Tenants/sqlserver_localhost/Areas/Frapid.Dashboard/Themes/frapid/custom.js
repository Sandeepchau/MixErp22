//Bikram Sambat to Gregorian Date Conversion utility for frapid
//Depends on linq.js, jQuery, and jQuery UI
(() => {
    //debugger;
    var definition = {
        style: `<style>
        .ui.bikram.sambat.date.popunder{
	        padding:1em;
	        border:1px solid #dadada;
	        width:300px;
	        height:160px;
	        background: #fff;
            font-size: 10px;
        }

        .ui.bikram.sambat.date.popunder input{
            width: 100%!important;
        }

        .ui.bikram.sambat.date.popunder select{
            font-size: 0.9em!important;
            height:3.0em!important;
        }

		.inverted	.ui.bikram.sambat.date.action.input  button.basic{
				border:2px solid #555!important;
			}

		.inverted	.ui.bikram.sambat.date.action.input  button.basic i{
			  color:#aaa;
			}

		.inverted .ui.bikram.sambat.date.action.input  button.basic:hover{
		background: #333!important;;
		}
        </style>`,
        popunderTemplate: `<div class="ui bikram sambat date popunder" style="display: none; position: absolute;">
                <div class ="ui big header">Select date </div>
                <div class="ui divider"></div>
                <div class="ui small form">
                    <div class="three fields">
                        <div class="field">
                            <label>year</label>
                            <input type="text" class ="year" />
                        </div>
                        <div class="field">
                            <label>month</label>
                            <select class ="month">
                                <option value="01">Jan</option>
                                <option value="02">Feb</option>
                                <option value="03">Mar </option>
                                <option value="04">Apr </option>
                                <option value="05">May </option>
                                <option value="06">June </option>
                                <option value="07">July </option>
                                <option value="08">Aug </option>
                                <option value="09">Sep </option>
                                <option value="10">Oct </option>
                                <option value="11">Nov </option>
                                <option value="12">Dec </option>
                            </select>
                        </div>
                        <div class="field">
                            <label>day</label>
                            <input type="text" class ="day" />
                        </div>
                    </div>
                    <div class ="ui small buttons">
                        <button class ="ui small positive button">OK</button>
                        <button class ="ui small negative button" onclick="$('.bikram.sambat.date.popunder').hide();">Cancle</button>
                    </div>
                </div>
            </div>`,
        months: ["january", "february", "march", "april", "may", "june", "july", "augest", "september", "october", "november", "december"],
        localizedMonthNames: ["बैशाख", "जेष्ठ", "आषाढ़", "श्रावण", "भाद्र", "आश्विन", "कार्तिक", "मार्ग", "पौष", "माघ", "फाल्गुन", "चैत्र"],
        datepickerFormat: window.datepickerFormat || "m/d/yy",//The expected jQuery UI datepicker date format.
        dates: [{ "bs_year_id": 2001, "start_date_in_ad": "2001-01-01", "january": 31, "february": 28, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2002, "start_date_in_ad": "2002-01-01", "january": 31, "february": 28, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2003, "start_date_in_ad": "2003-01-01", "january": 31, "february": 28, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2004, "start_date_in_ad": "2004-01-01", "january": 31, "february": 29, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2005, "start_date_in_ad": "2005-01-01", "january": 31, "february": 28, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2006, "start_date_in_ad": "2006-01-01", "january": 31, "february": 28, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2007, "start_date_in_ad": "2007-01-01", "january": 31, "february": 28, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2008, "start_date_in_ad": "2008-01-01", "january": 31, "february": 29, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2009, "start_date_in_ad": "2009-01-01", "january": 31, "february": 28, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2010, "start_date_in_ad": "2010-01-01", "january": 31, "february": 28, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2011, "start_date_in_ad": "2011-01-01", "january": 31, "february": 28, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2012, "start_date_in_ad": "2012-01-01", "january": 31, "february": 29, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2013, "start_date_in_ad": "2013-01-01", "january": 31, "february": 28, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2014, "start_date_in_ad": "2014-01-01", "january": 31, "february": 28, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2015, "start_date_in_ad": "2015-01-01", "january": 31, "february": 28, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2016, "start_date_in_ad": "2016-01-01", "january": 31, "february": 29, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2017, "start_date_in_ad": "2017-01-01", "january": 31, "february": 28, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2018, "start_date_in_ad": "2018-01-01", "january": 31, "february": 28, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2019, "start_date_in_ad": "2019-01-01", "january": 31, "february": 28, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2020, "start_date_in_ad": "2020-01-01", "january": 31, "february": 29, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2021, "start_date_in_ad": "2021-01-01", "january": 31, "february": 28, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2022, "start_date_in_ad": "2022-01-01", "january": 31, "february": 28, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2023, "start_date_in_ad": "2023-01-01", "january": 31, "february": 28, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2024, "start_date_in_ad": "2024-01-01", "january": 31, "february": 29, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2025, "start_date_in_ad": "2025-01-01", "january": 31, "february": 28, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2026, "start_date_in_ad": "2026-01-01", "january": 31, "february": 28, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2027, "start_date_in_ad": "2027-01-01", "january": 31, "february": 28, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2028, "start_date_in_ad": "2028-01-01", "january": 31, "february": 29, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2029, "start_date_in_ad": "2029-01-01", "january": 31, "february": 28, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2030, "start_date_in_ad": "2030-01-01", "january": 31, "february": 28, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2031, "start_date_in_ad": "2031-01-01", "january": 31, "february": 28, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2032, "start_date_in_ad": "2032-01-01", "january": 31, "february": 29, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2033, "start_date_in_ad": "2033-01-01", "january": 31, "february": 28, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2034, "start_date_in_ad": "2034-01-01", "january": 31, "february": 28, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2035, "start_date_in_ad": "2035-01-01", "january": 31, "february": 28, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2036, "start_date_in_ad": "2036-01-01", "january": 31, "february": 29, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2037, "start_date_in_ad": "2037-01-01", "january": 31, "february": 28, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2038, "start_date_in_ad": "2038-01-01", "january": 31, "february": 28, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2039, "start_date_in_ad": "2039-01-01", "january": 31, "february": 28, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2040, "start_date_in_ad": "2040-01-01", "january": 31, "february": 29, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2041, "start_date_in_ad": "2041-01-01", "january": 31, "february": 28, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2042, "start_date_in_ad": "2042-01-01", "january": 31, "february": 28, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2043, "start_date_in_ad": "2043-01-01", "january": 31, "february": 28, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2044, "start_date_in_ad": "2044-01-01", "january": 31, "february": 29, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2045, "start_date_in_ad": "2045-01-01", "january": 31, "february": 28, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2046, "start_date_in_ad": "2046-01-01", "january": 31, "february": 28, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2047, "start_date_in_ad": "2047-01-01", "january": 31, "february": 28, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2048, "start_date_in_ad": "2048-01-01", "january": 31, "february": 29, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2049, "start_date_in_ad": "2049-01-01", "january": 31, "february": 28, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2050, "start_date_in_ad": "2050-01-01", "january": 31, "february": 28, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2051, "start_date_in_ad": "2051-01-01", "january": 31, "february": 28, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2052, "start_date_in_ad": "2052-01-01", "january": 31, "february": 29, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2053, "start_date_in_ad": "2053-01-01", "january": 31, "february": 29, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2054, "start_date_in_ad": "2054-01-01", "january": 31, "february": 28, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2055, "start_date_in_ad": "2055-01-01", "january": 31, "february": 28, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2056, "start_date_in_ad": "2056-01-01", "january": 31, "february": 28, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2057, "start_date_in_ad": "2057-01-01", "january": 31, "february": 29, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2058, "start_date_in_ad": "2058-01-01", "january": 31, "february": 29, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2059, "start_date_in_ad": "2059-01-01", "january": 31, "february": 28, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2060, "start_date_in_ad": "2060-01-01", "january": 31, "february": 28, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2061, "start_date_in_ad": "2061-01-01", "january": 31, "february": 28, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2062, "start_date_in_ad": "2062-01-01", "january": 31, "february": 29, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2063, "start_date_in_ad": "2063-01-01", "january": 31, "february": 29, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2064, "start_date_in_ad": "2064-01-01", "january": 31, "february": 28, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2065, "start_date_in_ad": "2065-01-01", "january": 31, "february": 28, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2066, "start_date_in_ad": "2066-01-01", "january": 31, "february": 28, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2067, "start_date_in_ad": "2067-01-01", "january": 31, "february": 29, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2068, "start_date_in_ad": "2068-01-01", "january": 31, "february": 29, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2069, "start_date_in_ad": "2069-01-01", "january": 31, "february": 28, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2070, "start_date_in_ad": "2070-01-01", "january": 31, "february": 28, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2071, "start_date_in_ad": "2071-01-01", "january": 31, "february": 28, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2072, "start_date_in_ad": "2072-01-01", "january": 31, "february": 29, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },

            { "bs_year_id": 2073, "start_date_in_ad": "2073-01-01", "january": 31, "february": 28, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2074, "start_date_in_ad": "2074-01-01", "january": 31, "february": 28, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2075, "start_date_in_ad": "2075-01-01", "january": 31, "february": 28, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2076, "start_date_in_ad": "2076-01-01", "january": 31, "february": 29, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2077, "start_date_in_ad": "2077-01-01", "january": 31, "february": 28, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2078, "start_date_in_ad": "2078-01-01", "january": 31, "february": 28, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2079, "start_date_in_ad": "2079-01-01", "january": 31, "february": 28, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2080, "start_date_in_ad": "2080-01-01", "january": 31, "february": 29, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2081, "start_date_in_ad": "2081-01-01", "january": 31, "february": 28, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2082, "start_date_in_ad": "2082-01-01", "january": 31, "february": 28, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2083, "start_date_in_ad": "2083-01-01", "january": 31, "february": 28, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2084, "start_date_in_ad": "2084-01-01", "january": 31, "february": 29, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2085, "start_date_in_ad": "2085-01-01", "january": 31, "february": 28, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2086, "start_date_in_ad": "2086-01-01", "january": 31, "february": 28, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2087, "start_date_in_ad": "2087-01-01", "january": 31, "february": 28, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2088, "start_date_in_ad": "2088-01-01", "january": 31, "february": 29, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2089, "start_date_in_ad": "2089-01-01", "january": 31, "february": 28, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2090, "start_date_in_ad": "2090-01-01", "january": 31, "february": 28, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2091, "start_date_in_ad": "2091-01-01", "january": 31, "february": 28, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2092, "start_date_in_ad": "2092-01-01", "january": 31, "february": 29, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },

            { "bs_year_id": 2093, "start_date_in_ad": "2093-01-01", "january": 31, "february": 28, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2094, "start_date_in_ad": "2094-01-01", "january": 31, "february": 28, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2095, "start_date_in_ad": "2095-01-01", "january": 31, "february": 28, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2096, "start_date_in_ad": "2096-01-01", "january": 31, "february": 29, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2097, "start_date_in_ad": "2097-01-01", "january": 31, "february": 28, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2098, "start_date_in_ad": "2098-01-01", "january": 31, "february": 28, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2099, "start_date_in_ad": "2099-01-01", "january": 31, "february": 28, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2100, "start_date_in_ad": "2100-01-01", "january": 31, "february": 29, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2101, "start_date_in_ad": "2101-01-01", "january": 31, "february": 28, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2102, "start_date_in_ad": "2102-01-01", "january": 31, "february": 28, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2103, "start_date_in_ad": "2103-01-01", "january": 31, "february": 28, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2104, "start_date_in_ad": "2104-01-01", "january": 31, "february": 29, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2105, "start_date_in_ad": "2105-01-01", "january": 31, "february": 28, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2106, "start_date_in_ad": "2106-01-01", "january": 31, "february": 28, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2107, "start_date_in_ad": "2107-01-01", "january": 31, "february": 28, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2108, "start_date_in_ad": "2108-01-01", "january": 31, "february": 29, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2109, "start_date_in_ad": "2109-01-01", "january": 31, "february": 28, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2110, "start_date_in_ad": "2110-01-01", "january": 31, "february": 28, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2111, "start_date_in_ad": "2111-01-01", "january": 31, "february": 28, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2112, "start_date_in_ad": "2112-01-01", "january": 31, "february": 29, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2113, "start_date_in_ad": "2113-01-01", "january": 31, "february": 28, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2114, "start_date_in_ad": "2114-01-01", "january": 31, "february": 28, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2115, "start_date_in_ad": "2115-01-01", "january": 31, "february": 28, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2116, "start_date_in_ad": "2116-01-01", "january": 31, "february": 29, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },

            { "bs_year_id": 2117, "start_date_in_ad": "2117-01-01", "january": 31, "february": 28, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2118, "start_date_in_ad": "2118-01-01", "january": 31, "february": 28, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2119, "start_date_in_ad": "2119-01-01", "january": 31, "february": 28, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2120, "start_date_in_ad": "2120-01-01", "january": 31, "february": 29, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2121, "start_date_in_ad": "2121-01-01", "january": 31, "february": 28, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2122, "start_date_in_ad": "2122-01-01", "january": 31, "february": 28, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2123, "start_date_in_ad": "2123-01-01", "january": 31, "february": 28, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2124, "start_date_in_ad": "2124-01-01", "january": 31, "february": 29, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2125, "start_date_in_ad": "2125-01-01", "january": 31, "february": 28, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2126, "start_date_in_ad": "2126-01-01", "january": 31, "february": 28, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2127, "start_date_in_ad": "2127-01-01", "january": 31, "february": 28, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2128, "start_date_in_ad": "2128-01-01", "january": 31, "february": 29, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2129, "start_date_in_ad": "2129-01-01", "january": 31, "february": 28, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2130, "start_date_in_ad": "2130-01-01", "january": 31, "february": 28, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2131, "start_date_in_ad": "2131-01-01", "january": 31, "february": 28, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2132, "start_date_in_ad": "2132-01-01", "january": 31, "february": 29, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2133, "start_date_in_ad": "2133-01-01", "january": 31, "february": 28, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2134, "start_date_in_ad": "2134-01-01", "january": 31, "february": 28, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2135, "start_date_in_ad": "2135-01-01", "january": 31, "february": 28, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2136, "start_date_in_ad": "2136-01-01", "january": 31, "february": 29, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2137, "start_date_in_ad": "2137-01-01", "january": 31, "february": 28, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2138, "start_date_in_ad": "2138-01-01", "january": 31, "february": 28, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2139, "start_date_in_ad": "2139-01-01", "january": 31, "february": 28, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2140, "start_date_in_ad": "2140-01-01", "january": 31, "february": 29, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },

            { "bs_year_id": 2141, "start_date_in_ad": "2141-01-01", "january": 31, "february": 28, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2142, "start_date_in_ad": "2142-01-01", "january": 31, "february": 28, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2143, "start_date_in_ad": "2143-01-01", "january": 31, "february": 28, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2144, "start_date_in_ad": "2144-01-01", "january": 31, "february": 29, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2145, "start_date_in_ad": "2145-01-01", "january": 31, "february": 28, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2146, "start_date_in_ad": "2146-01-01", "january": 31, "february": 28, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2147, "start_date_in_ad": "2147-01-01", "january": 31, "february": 28, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2148, "start_date_in_ad": "2148-01-01", "january": 31, "february": 29, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2149, "start_date_in_ad": "2149-01-01", "january": 31, "february": 28, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2150, "start_date_in_ad": "2150-01-01", "january": 31, "february": 28, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2151, "start_date_in_ad": "2151-01-01", "january": 31, "february": 28, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2152, "start_date_in_ad": "2152-01-01", "january": 31, "february": 29, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2153, "start_date_in_ad": "2153-01-01", "january": 31, "february": 28, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2154, "start_date_in_ad": "2154-01-01", "january": 31, "february": 28, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2155, "start_date_in_ad": "2155-01-01", "january": 31, "february": 28, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2156, "start_date_in_ad": "2156-01-01", "january": 31, "february": 29, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2157, "start_date_in_ad": "2157-01-01", "january": 31, "february": 28, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2158, "start_date_in_ad": "2158-01-01", "january": 31, "february": 28, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2159, "start_date_in_ad": "2159-01-01", "january": 31, "february": 28, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2160, "start_date_in_ad": "2160-01-01", "january": 31, "february": 29, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },

            { "bs_year_id": 2161, "start_date_in_ad": "2161-01-01", "january": 31, "february": 28, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2162, "start_date_in_ad": "2162-01-01", "january": 31, "february": 28, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2163, "start_date_in_ad": "2163-01-01", "january": 31, "february": 28, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2164, "start_date_in_ad": "2164-01-01", "january": 31, "february": 29, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2165, "start_date_in_ad": "2165-01-01", "january": 31, "february": 28, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2166, "start_date_in_ad": "2166-01-01", "january": 31, "february": 28, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2167, "start_date_in_ad": "2167-01-01", "january": 31, "february": 28, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2168, "start_date_in_ad": "2168-01-01", "january": 31, "february": 29, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2169, "start_date_in_ad": "2169-01-01", "january": 31, "february": 28, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2170, "start_date_in_ad": "2170-01-01", "january": 31, "february": 28, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2171, "start_date_in_ad": "2171-01-01", "january": 31, "february": 28, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2172, "start_date_in_ad": "2172-01-01", "january": 31, "february": 29, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },

            { "bs_year_id": 2173, "start_date_in_ad": "2173-01-01", "january": 31, "february": 28, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2174, "start_date_in_ad": "2174-01-01", "january": 31, "february": 28, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2175, "start_date_in_ad": "2175-01-01", "january": 31, "february": 28, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2176, "start_date_in_ad": "2176-01-01", "january": 31, "february": 29, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2177, "start_date_in_ad": "2177-01-01", "january": 31, "february": 28, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2178, "start_date_in_ad": "2178-01-01", "january": 31, "february": 28, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2179, "start_date_in_ad": "2179-01-01", "january": 31, "february": 28, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2180, "start_date_in_ad": "2180-01-01", "january": 31, "february": 29, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2181, "start_date_in_ad": "2181-01-01", "january": 31, "february": 28, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2182, "start_date_in_ad": "2182-01-01", "january": 31, "february": 28, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2183, "start_date_in_ad": "2183-01-01", "january": 31, "february": 28, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2184, "start_date_in_ad": "2184-01-01", "january": 31, "february": 29, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2185, "start_date_in_ad": "2185-01-01", "january": 31, "february": 28, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2186, "start_date_in_ad": "2186-01-01", "january": 31, "february": 28, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2187, "start_date_in_ad": "2187-01-01", "january": 31, "february": 28, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2188, "start_date_in_ad": "2188-01-01", "january": 31, "february": 29, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2189, "start_date_in_ad": "2189-01-01", "january": 31, "february": 28, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2190, "start_date_in_ad": "2190-01-01", "january": 31, "february": 28, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2191, "start_date_in_ad": "2191-01-01", "january": 31, "february": 28, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2192, "start_date_in_ad": "2192-01-01", "january": 31, "february": 29, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },

            { "bs_year_id": 2193, "start_date_in_ad": "2193-01-01", "january": 31, "february": 29, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2194, "start_date_in_ad": "2194-01-01", "january": 31, "february": 28, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2195, "start_date_in_ad": "2195-01-01", "january": 31, "february": 28, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2196, "start_date_in_ad": "2196-01-01", "january": 31, "february": 28, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2197, "start_date_in_ad": "2197-01-01", "january": 31, "february": 29, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2198, "start_date_in_ad": "2198-01-01", "january": 31, "february": 29, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2199, "start_date_in_ad": "2199-01-01", "january": 31, "february": 28, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2200, "start_date_in_ad": "2200-01-01", "january": 31, "february": 28, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2201, "start_date_in_ad": "2201-01-01", "january": 31, "february": 28, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2202, "start_date_in_ad": "2202-01-01", "january": 31, "february": 29, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2203, "start_date_in_ad": "2203-01-01", "january": 31, "february": 29, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2204, "start_date_in_ad": "2204-01-01", "january": 31, "february": 28, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2205, "start_date_in_ad": "2205-01-01", "january": 31, "february": 28, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2206, "start_date_in_ad": "2206-01-01", "january": 31, "february": 28, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2207, "start_date_in_ad": "2207-01-01", "january": 31, "february": 29, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2208, "start_date_in_ad": "2208-01-01", "january": 31, "february": 29, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2209, "start_date_in_ad": "2209-01-01", "january": 31, "february": 28, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2210, "start_date_in_ad": "2210-01-01", "january": 31, "february": 28, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2211, "start_date_in_ad": "2211-01-01", "january": 31, "february": 28, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
            { "bs_year_id": 2212, "start_date_in_ad": "2212-01-01", "january": 31, "february": 29, "march": 31, "april": 30, "may": 31, "june": 30, "july": 31, "augest": 31, "september": 30, "october": 31, "november": 30, "december": 31 },
                /*{ "bs_year_id": 2208, "start_date_in_ad": "2151-04-16", "baisakh": 31, "jestha": 32, "ashadh": 31, "shrawan": 32, "bhadra": 31, "ashwin": 30, "kartik": 30, "marg": 30, "poush": 29, "magh": 29, "falgun": 30, "chaitra": 31 }*/]
    };


    if (!$('.ui.bikram.sambat.date.popunder').length) {
        $("body").prepend(definition.popunderTemplate);
        $(definition.style).appendTo("head");

        var popunder = $('.ui.bikram.sambat.date.popunder');
        popunder.find("input.year, input.day, select.month").on("change", function () {
            bsDateEventTrigger(this);
        });

        popunder.find("button.positive").off("click").on("click", function () {
            bsDateEventTrigger(this, true);
        });
    };


    //Returns Bikram Sambat month name from month number
    function getMonthName(monthNumber) {
        if (monthNumber >= 0 && monthNumber <= 11) {
            return definition.localizedMonthNames[monthNumber - 1];
        };

        return "";
    };

    //Returns starting date in Anno Domini format from Bikram Sambat Year
    function getStartDateInAd(bsYearId) {
        const startDate = window.Enumerable
            .From(definition.dates)
            .Where(function (x) {
                return x.bs_year_id === bsYearId;
            })
            .FirstOrDefault()
            .start_date_in_ad;

        return new Date(startDate);
    };

    //Returns a list of months with respective number of days
    function getMonthDayList(year) {
       
        var monthDayList = [];

        if (!year) {
            //Cannot work with an invalid object
            return monthDayList;
        };

        $.each(definition.months, function () {
            const month = year[this];
            monthDayList.push(month);
        });

        return monthDayList;
    };

    //Returns the number of days elapsed since the beginning of the Bikram Sambat year.
    function getElapsedDays(yearId, monthId, dayId) {
        
        var totalDays = 0;

        const year = window.Enumerable.From(definition.dates)
            .Where(function (x) {
                return x.bs_year_id === yearId;
            }).FirstOrDefault();

        const monthsInYear = getMonthDayList(year);

        for (let i = 0; i < monthId - 1; i++) {
            totalDays += monthsInYear[i];
        };

        totalDays += dayId;

        return totalDays - 1;
    };

    //Converts the Bikram Sambat date to AD format.
    function getAdDate(bsDate) {
        //debugger;
        const date = bsDate.split("/");

        const yearId = window.parseInt(date[0]);
        const monthId = window.parseInt(date[1]);
        const dayId = window.parseInt(date[2]);

        if (yearId > 9999) {
            return null;
        };

        const totalDays = getElapsedDays(yearId, monthId, dayId);
        const startDate = getStartDateInAd(yearId);

        return $.datepicker.formatDate(definition.datepickerFormat, new Date(yearId, monthId, dayId));
    };


    //Gets the number of elapsed days between two dates.
    function dateDiff(first, second) {
        const firstDate = Date.UTC(first.getFullYear(), first.getMonth(), first.getDate());
        const secondDate = Date.UTC(second.getFullYear(), second.getMonth(), second.getDate());

        return Math.floor((secondDate - firstDate) / (1000 * 60 * 60 * 24));
    };

    function getSliced(num) {
        return ("0" + num).slice(-2);
    };

    //Converts the AD date to Bikram Sambat date format.
    function getBsDate(adDate) {
        //debugger;
        //find the closest year
        const year = window.Enumerable.From(definition.dates)
            .Where(function (x) {
                return new Date(x.start_date_in_ad) <= adDate;
            }).OrderByDescending(function (x) {
                return x.bs_year_id;
            }).FirstOrDefault();

            const startDate = new Date(year.start_date_in_ad);
            var totalDays = dateDiff(startDate, adDate);


            const monthsInYear = getMonthDayList(year);
            var counter = 1;

            $.each(monthsInYear, function () {
                const days = this;

                if (totalDays < days) {
                    return false;
                };

                totalDays -= days;
                counter++;
            });

            const yearId = year.bs_year_id;
            const monthId = counter;
            const dayId = totalDays + 1;

            return yearId + "/" + getSliced(monthId) + "/" + getSliced(dayId);
       
    };


    function displayBsDatePopUnder(activator) {

        function displayBsDate(container) {
            const input = container.find("input.date.hasDatepicker");
            const date = input.datepicker("getDate");
            const bs = getBsDate(date);
           // const bs = new Date(date).toString("yyyy/MM/dd");

                const segments = bs.split("/");
                const year = segments[0];
                const month = segments[1];
                const day = segments[2];

                container.find("input.year").val(year);
                container.find("select.month").val(month);
                container.find("input.day").val(day);

        };

        const container = activator.parent();
        const popunder = $('.ui.bikram.sambat.date.popunder');

        if (!container.find(".ui.bikram.sambat.date.popunder").length) {
            container.append(popunder);
        };

        const input = container.find("input.date.hasDatepicker");

        input.on("keyup blur", function () {
            displayBsDate(container);
        });

        input.trigger("blur");
        window.popUnder(popunder, activator);
    };

    function bsDateEventTrigger(el, close) {
       //debugger;
        const container = $(el).closest(".ui.bikram.sambat.date.input");
        const year = container.find("input.year").val();
        const month = container.find("select.month").val();
        const day = container.find("input.day").val();

        if (!window.parseInt(year) || !window.parseInt(month) || !window.parseInt(day)) {
            return;
        };

        if (day > 31) {
            container.find("input.day").val("1");
            return;
        };

        const bs = [year, month, getSliced(day)].join("/");
        //const date = getAdDate(bs);

        const date = new Date(bs).toLocaleDateString();
        const input = container.find("input.date.hasDatepicker");
        input.datepicker("setDate", date);

        if (close) {
            $(".bikram.sambat.date.popunder").hide();
        };
    };

    function subroutine() {
        const candidates = $(".date.hasDatepicker:not(.hasBsDate)");

        if (candidates.length > 0) {
            console.log("Found " + candidates.length + " element(s) to inject BS date extension to.");

            $.each(candidates, function () {
                const el = $(this);
                if (!el.parent().is(".bikram.sambat.date.action.input")) {
                    el.wrap(`<div class="ui bikram sambat date action fluid input" />`);
                    const button = $(`<button class="ui basic icon button" title="Select date">
                            <i class="calendar icon"></i>
                            </button>`);

                    button.off("click").on("click", function () {
                        displayBsDatePopUnder($(this));
                    });

                    el.parent().append(button);

                    el.addClass("hasBsDate");
                };
            });
        };
		
		const textNodes = $("div.to.bs.date:not(.hasBsDate), span.to.bs.date:not(.hasBsDate)");
		
		if(textNodes.length > 0){
			$.each(textNodes, function(){
                const el = $(this);
				var value = new Date(el.text());
				
				if(value){
					el.attr("title", "Date in AD: " + el.text());
					el.text(getBsDate(value)).addClass("hasBsDate");				
				};
				
			});
		};
    };

    setTimeout(function () {
        subroutine();
    }, 1000);

    window.setInterval(subroutine, 10000);
})();

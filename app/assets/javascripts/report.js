/**
 * User: nmeylan
 * Date: 07.12.14
 * Time: 15:39
 */
function bind_agile_board_reports() {
    createOverlay("#statistics-help", 150);
    $('#statistics-info').click(function (e) {
        jQuery('#statistics-help').overlay().load();
    });
}
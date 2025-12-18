// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get applicationName => 'Trình phát nhạc';

  @override
  String get languageTitle => 'Ngôn ngữ';

  @override
  String langOptionDisplayName(String languageCode) {
    String _temp0 = intl.Intl.selectLogic(
      languageCode,
      {
        'vi': 'Tiếng Việt',
        'en': 'English',
        'other': 'Hệ Thống',
      },
    );
    return '$_temp0';
  }

  @override
  String get settingTitle => 'Cài đặt';

  @override
  String get setting_playerTitle => 'Trình phát nhạc';

  @override
  String get setting_themeTitle => 'Giao diện chủ đề';

  @override
  String get theme_lightMode => 'Sáng';

  @override
  String get theme_darkMode => 'Tối';

  @override
  String get theme_auto => 'Hệ thống';

  @override
  String get settingPlayer_skipSilence => 'Bỏ qua khoảng lặng';

  @override
  String get settingPlayer_autoVolume => 'To/nhỏ dần khi phát/tạm dừng, chuyển bài';

  @override
  String get settingPlayer_autoScan => 'Tự động quét nhạc';

  @override
  String get settingPlayer_background => 'Hình nền';

  @override
  String get setting_aboutTitle => 'Thông tin ứng dụng';

  @override
  String get about_intro => 'Giới thiệu';

  @override
  String get about_version => 'Phiên bản';

  @override
  String get about_contact => 'Thông tin & Hỗ trợ';

  @override
  String get setting_deleteDataPermanently => 'Xóa dữ liệu';

  @override
  String get setting_deleteDataPermanentlyConfirmMessage => 'Xóa tất cả dữ liệu, sau khi xóa, bạn cần khởi động lại app?';

  @override
  String get setting_deleteDataPermanentlySuccess => 'Đã xóa dữ liệu, vui lòng khởi động lại app...';

  @override
  String get dashboard_playingRecently => 'Đã phát gần đây';

  @override
  String get dashboard_viewMore => 'Xem thêm >';

  @override
  String get dashboard_newFiles => 'Đã thêm gần đây';

  @override
  String get dashboard_mostListening => 'Lượt nghe nhiều nhất';

  @override
  String get dashboard_noSongsToPlay => 'Không có bài hát nào để phát';

  @override
  String get musicMenu_play => 'Phát';

  @override
  String get musicMenu_playNext => 'Phát tiếp theo';

  @override
  String get musicMenu_addToFavorite => 'Thêm vào Yêu thích';

  @override
  String get musicMenu_addToFavoriteSuccess => 'Đã thêm vào Yêu thích';

  @override
  String get musicMenu_removeFromFavorite => 'Xóa khỏi Yêu thích';

  @override
  String get musicMenu_removeFromFavoriteSuccess => 'Đã xóa khỏi Yêu thích';

  @override
  String get musicMenu_addToLibrary => 'Thêm vào thư viện';

  @override
  String get musicMenu_removeFromLibrary => 'Xóa khỏi thư viện';

  @override
  String musicMenu_removeFromLibrarySuccess(Object musicTitle) {
    return 'Đã xóa bài hát \"$musicTitle\" khỏi thư viện';
  }

  @override
  String get musicMenu_setStopTime => 'Hẹn giờ ngủ';

  @override
  String get musicMenu_changeThumbnail => 'Đổi ảnh bìa';

  @override
  String get musicMenu_removeThumbnail => 'Xóa ảnh bìa';

  @override
  String musicMenu_removeThumbnailSuccess(Object name) {
    return 'Đã xóa ảnh bìa \"$name\"';
  }

  @override
  String get musicMenu_changePlayerTheme => 'Đổi giao diện';

  @override
  String musicMenu_musicShown(Object name) {
    return 'Đã hiển thị \"$name\"';
  }

  @override
  String musicMenu_musicHidden(Object name) {
    return 'Đã ẩn \"$name\"';
  }

  @override
  String get musicMenu_show => 'Hiển thị';

  @override
  String get musicMenu_hide => 'Ẩn';

  @override
  String get musicMenu_deleteOnDevice => 'Xóa khỏi thiết bị';

  @override
  String musicMenu_playNextMessage(Object musicTitle) {
    return 'Tiếp theo sẽ phát bài \"$musicTitle\"';
  }

  @override
  String get musicMenu_error => 'Xảy ra lỗi';

  @override
  String get musicMenu_removeFromPlaylist => 'Xóa khỏi danh sách phát';

  @override
  String musicMenu_removeFromPlaylistSuccess(Object musicTitle) {
    return 'Đã xóa \"$musicTitle\" khỏi danh sách phát';
  }

  @override
  String get musicMenu_notFoundLibrary => 'Không tìm thấy thư viện';

  @override
  String musicMenu_musicPauseAfter(Object time) {
    return 'Tắt nhạc sau $time';
  }

  @override
  String get musicMenu_turnOffSetStopTime => 'Đã tắt hẹn giờ ngủ';

  @override
  String get libraryMenu_addItems => 'Thêm bài hát vào thư viện';

  @override
  String get libraryMenu_edit => 'Sửa thông tin';

  @override
  String get libraryMenu_sortItems => 'Sắp xếp bài hát';

  @override
  String get libraryMenu_downloadItemThumbnails => 'Tải ảnh bìa cho tất cả bài hát';

  @override
  String get libraryMenu_deleteLibrary => 'Xóa thư viện';

  @override
  String get createLibraryTitle => 'Tạo thư viện';

  @override
  String get libraryName => 'Tên thư viện';

  @override
  String get error_requiredName => 'Tên không được để trống';

  @override
  String get error_checkAgain => 'Vui lòng kiểm tra lại thông tin';

  @override
  String get error_existedName => 'Tên đã tồn tại';

  @override
  String get error_cannotDeletePlayingMusic => 'Bài hát đang phát, không thể xóa';

  @override
  String get searchPlaceholder => 'Tìm kiếm';

  @override
  String get searchNoResults => 'Không có kết quả';

  @override
  String get noData => 'Không có dữ liệu';

  @override
  String get formAction_confirm => 'Xác nhận';

  @override
  String get formAction_cancel => 'Hủy';

  @override
  String get detailTitle => 'Chi tiết';

  @override
  String get detail_title => 'Tiêu đề';

  @override
  String get detail_album => 'Album';

  @override
  String get detail_artist => 'Nghệ sĩ';

  @override
  String get detail_genre => 'Thể loại';

  @override
  String get detail_length => 'Thời lượng';

  @override
  String get detail_size => 'Kích thước';

  @override
  String get detail_filePath => 'Vị trí';

  @override
  String get detail_creationDate => 'Ngày tạo';

  @override
  String get detail_lastModificationDate => 'Sửa lần cuối';

  @override
  String get detail_empty => '<trống>';

  @override
  String get folderName => 'Tên thư mục';

  @override
  String get sortByTitle => 'Sắp xếp theo';

  @override
  String get sortField_musicName => 'Tên bài hát';

  @override
  String get sortField_artist => 'Tên nghệ sĩ';

  @override
  String get sortField_length => 'Độ dài';

  @override
  String get sortField_newest => 'Mới nhất';

  @override
  String get sortField_oldest => 'Cũ nhất';

  @override
  String get sortDirectionTitle => 'Theo thứ tự';

  @override
  String get sortDirection_ascending => 'Tăng dần (A ⇀ Z)';

  @override
  String get sortDirection_descending => 'Giảm dần (Z ⇀ A)';

  @override
  String get playMusic => 'Phát nhạc';

  @override
  String get playMusicRandom => 'Ngẫu nhiên';

  @override
  String get favorites => 'Yêu thích';

  @override
  String get songTitle => 'Bài hát';

  @override
  String get setStopTimeTitle => 'Hẹn giờ ngủ';

  @override
  String get remainingTitle => 'Còn lại';

  @override
  String get playlistTitle => 'Danh sách phát';

  @override
  String nHours(num hour) {
    final intl.NumberFormat hourNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
      
    );
    final String hourString = hourNumberFormat.format(hour);

    String _temp0 = intl.Intl.pluralLogic(
      hour,
      locale: localeName,
      other: '$hourString giờ',
    );
    return '$_temp0';
  }

  @override
  String nMinutes(num minute) {
    final intl.NumberFormat minuteNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
      
    );
    final String minuteString = minuteNumberFormat.format(minute);

    String _temp0 = intl.Intl.pluralLogic(
      minute,
      locale: localeName,
      other: '$minuteString phút',
    );
    return '$_temp0';
  }

  @override
  String nSeconds(num seconds) {
    final intl.NumberFormat secondsNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
      
    );
    final String secondsString = secondsNumberFormat.format(seconds);

    String _temp0 = intl.Intl.pluralLogic(
      seconds,
      locale: localeName,
      other: '$secondsString giây',
    );
    return '$_temp0';
  }

  @override
  String get changePlayerThemeTitle => 'Đổi giao diện';

  @override
  String nSongs(int count) {
    return '$count bài hát';
  }

  @override
  String home_tab(String id) {
    String _temp0 = intl.Intl.selectLogic(
      id,
      {
        'recommended': 'Đề xuất',
        'songs': 'Bài hát',
        'libraries': 'Thư viện',
        'folders': 'Thư mục',
        'other': '',
      },
    );
    return '$_temp0';
  }

  @override
  String get message_addMusicToLibrarySuccess => 'Đã thêm bài hát vào thư viện';

  @override
  String get library_musicExists => ' (đã có bài hát này)';

  @override
  String get deleteLibraryPopupTitle => 'Xóa thư viện';

  @override
  String deleteLibraryPopUpMessage(Object libraryTitle) {
    return 'Bạn chắc chắn muốn xóa thư viện \"$libraryTitle\"?';
  }

  @override
  String deleteLibrarySuccess(Object title) {
    return 'Đã xóa thư viện \"$title\"';
  }

  @override
  String get status_saving => 'Đang lưu...';

  @override
  String get status_completed => 'Hoàn thành!';

  @override
  String get status_waiting => 'Vui lòng chờ chút';

  @override
  String get status_loading => 'Đang tải...';

  @override
  String downloadThumbnail_progress(Object percent) {
    return 'Tiến độ: $percent%';
  }

  @override
  String downloadThumbnail_totalCount(Object total) {
    return 'Tổng: $total';
  }

  @override
  String downloadThumbnail_existsCount(Object total) {
    return 'Đã có (không tải nữa): $total';
  }

  @override
  String downloadThumbnail_successCount(Object total) {
    return 'Tải thành công: $total';
  }

  @override
  String downloadThumbnail_failedCount(Object total) {
    return 'Tải thất bại: $total';
  }

  @override
  String get cancel => 'Hủy bỏ';

  @override
  String get save => 'Lưu';

  @override
  String get folderMenu_createLibraryDuplicatedMessage => 'Thư viện đã tồn tại, bạn có muốn thêm tất cả bài hát trong thư mục này vào thư viện cùng tên hay không?';

  @override
  String folderMenu_createLibrarySuccess(Object name) {
    return 'Đã tạo thư viện \"$name\"';
  }

  @override
  String get folderMenu_displayFolder => 'Hiển thị thư mục';

  @override
  String get folderMenu_hideFolder => 'Ẩn thư mục';

  @override
  String folderMenu_displayAllFiles(int totalHiddenFile) {
    return 'Hiển thị tất cả tệp ($totalHiddenFile tệp)';
  }

  @override
  String get folderMenu_hideAllFiles => 'Ẩn tất cả tệp';

  @override
  String get scanMusic => 'Quét nhạc';

  @override
  String get scanMusic_scaning => 'Đang quét nhạc...';

  @override
  String get scanMusic_scanCompleted => 'Quét thành công';

  @override
  String get scanMusic_noNewFile => 'không có tệp mới';

  @override
  String scanMusic_nNewFiles(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bài hát',
    );
    return 'đã thêm $_temp0';
  }

  @override
  String scanMusic_newDeletedFiles(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bài hát',
    );
    return 'gỡ bỏ $_temp0 vì không tìm thấy tệp trên thiết bị';
  }

  @override
  String get scanMusic_noPermission => 'Không có quyền truy cập bộ nhớ để quét nhạc. Vui lòng cấp quyền \"Quản lý tất cả tệp\"';

  @override
  String get hiddenFolder => 'Thư mục ẩn';

  @override
  String nHiddenFiles(int count) {
    return '$count tệp ẩn';
  }

  @override
  String nFolders(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      one: '1 folder',
      other: '$count folders',
    );
    return '$_temp0';
  }

  @override
  String nFiles(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      one: '1 file',
      other: '$count files',
    );
    return '$_temp0';
  }

  @override
  String get and => 'và';

  @override
  String nBeHidden(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'bị ẩn',
    );
    return '$_temp0';
  }

  @override
  String get viewHiddenFiles => 'Xem tệp bị ẩn';

  @override
  String get hideHiddenFiles => 'Không hiển thị tệp ẩn';

  @override
  String get music_hidden => 'Bị ẩn';

  @override
  String get music_unknownArtist => '<Không rõ tác giả>';

  @override
  String nLibraries(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count thư viện',
    );
    return '$_temp0';
  }

  @override
  String get noLibraries => 'Chưa có thư viện nào!';

  @override
  String get createNew => 'Tạo mới';

  @override
  String get removeAllFromFavorite => 'Gỡ bỏ tất cả';

  @override
  String get removeAllFromFavoriteSuccess => 'Đã gỡ bỏ tất cả bài hát khỏi mục Yêu thích';

  @override
  String get emptyList => 'Danh sách trống!';

  @override
  String get addSongsToLibrary => 'Thêm bài hát';

  @override
  String nLastDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ngày gần đây',
    );
    return '$_temp0';
  }

  @override
  String get libraryTitle => 'Thư viện';

  @override
  String get folderTitle => 'Thư mục';

  @override
  String get allSongs => 'Tất cả bài hát';

  @override
  String get doneTitle => 'Xong';

  @override
  String get selectAll => 'Chọn tất cả';

  @override
  String get selected => 'Đã chọn';

  @override
  String get displayedAllResult => 'Đã hiển thị tất cả kết quả!';

  @override
  String get pictureProvidedByYoutube => 'Ảnh cung cấp bởi Youtube';

  @override
  String get errorTryAgain => 'Xảy ra lỗi, vui lòng thử lại!';

  @override
  String changeMusicThumbnailSuccess(Object title) {
    return 'Đã cập nhật ảnh bìa cho \"\$$title\"';
  }

  @override
  String get themeIsUsed => 'Đang dùng';

  @override
  String get themeApply => 'Áp dụng';

  @override
  String get auto => 'Tự động';

  @override
  String get picture => 'Hình';

  @override
  String get blur => 'Độ mờ';

  @override
  String get optionsTitle => 'Tùy chỉnh';

  @override
  String get stopAfter => 'Dừng sau';

  @override
  String get createLibrary => 'Tạo thư viện';

  @override
  String get updateLibrary => 'Cập nhật thư viện';

  @override
  String get off => 'Tắt';

  @override
  String get playlist_shuffleSuccess => 'Đã trộn danh sách';

  @override
  String get playlist_removeAllItemsConfirmMessage => 'Xóa tất cả bài hát khỏi danh sách phát?';

  @override
  String get confirmDialog_defaultTitle => 'Xác nhận';

  @override
  String get confirmDialog_defaultMessage => 'Bạn chắc chắn?';

  @override
  String get nowPlayingTitle => 'Đang phát';

  @override
  String get okTitle => 'OK';

  @override
  String notFoundFileName(Object name) {
    return 'Không tìm thấy tệp \"$name\"';
  }

  @override
  String deleteMusicSuccess(Object name) {
    return 'Đã xóa \"$name\n';
  }

  @override
  String deleteMusicConfirmMessage(Object title) {
    return 'Bạn có chắc chắn muốn xóa \"$title\" khỏi thiết bị?';
  }

  @override
  String get customTitle => 'Tùy chỉnh';

  @override
  String get defaultTitle => 'Mặc định';

  @override
  String get allowTitle => 'Cho phép';

  @override
  String get requestNotificationPermissionTitle => 'Cấp quyền Thông báo';

  @override
  String get requestNotificationPermissionMessage => 'Vui lòng cấp quyền thông báo để hiển thị và tạm dừng hoặc chuyển bài hát nhanh chóng trên Trung tâm thông báo.';

  @override
  String get requestStoragePermissionTitle => 'Cấp quyền Quản lý tệp';

  @override
  String get requestStoragePermissionMessage => 'Vui lòng cấp quyền \"Quản lý tất cả tệp\" để ứng dụng có thể truy cập bộ nhớ và quét các tệp tin âm thanh có trong thiết bị của bạn.';
}

// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get applicationName => 'Music Player';

  @override
  String get languageTitle => 'Language';

  @override
  String langOptionDisplayName(String languageCode) {
    String _temp0 = intl.Intl.selectLogic(
      languageCode,
      {
        'vi': 'Tiếng Việt',
        'en': 'English',
        'other': 'System',
      },
    );
    return '$_temp0';
  }

  @override
  String get settingTitle => 'Settings';

  @override
  String get setting_playerTitle => 'Music Player';

  @override
  String get setting_themeTitle => 'Theme';

  @override
  String get theme_lightMode => 'Light';

  @override
  String get theme_darkMode => 'Dark';

  @override
  String get theme_auto => 'System';

  @override
  String get settingPlayer_skipSilence => 'Skip silence';

  @override
  String get settingPlayer_autoVolume => 'Fade in/out when playing/pausing or switching tracks';

  @override
  String get settingPlayer_autoScan => 'Auto scan files';

  @override
  String get settingPlayer_background => 'Background';

  @override
  String get setting_aboutTitle => 'App Information';

  @override
  String get about_intro => 'Introduction';

  @override
  String get about_version => 'Version';

  @override
  String get about_contact => 'Info & Support';

  @override
  String get setting_deleteDataPermanently => 'Delete data';

  @override
  String get setting_deleteDataPermanentlyConfirmMessage => 'Are you sure to delete all data?. After deletion, you need to restart the app.';

  @override
  String get setting_deleteDataPermanentlySuccess => 'All data is deleted, please restart the application...';

  @override
  String get dashboard_playingRecently => 'Recently Played';

  @override
  String get dashboard_viewMore => 'View more >';

  @override
  String get dashboard_newFiles => 'Recently Added';

  @override
  String get dashboard_mostListening => 'Most Listened';

  @override
  String get dashboard_noSongsToPlay => 'No songs to play';

  @override
  String get musicMenu_play => 'Play';

  @override
  String get musicMenu_playNext => 'Play Next';

  @override
  String get musicMenu_addToFavorite => 'Add to favorites';

  @override
  String get musicMenu_addToFavoriteSuccess => 'Add to favorites is success';

  @override
  String get musicMenu_removeFromFavorite => 'Remove from favorites';

  @override
  String get musicMenu_removeFromFavoriteSuccess => 'Remove from favorites is success';

  @override
  String get musicMenu_addToLibrary => 'Add to library';

  @override
  String get musicMenu_removeFromLibrary => 'Remove from library';

  @override
  String musicMenu_removeFromLibrarySuccess(Object musicTitle) {
    return '\"$musicTitle\" is removed';
  }

  @override
  String get musicMenu_setStopTime => 'Sleep Timer';

  @override
  String get musicMenu_changeThumbnail => 'Change cover image';

  @override
  String get musicMenu_removeThumbnail => 'Remove cover image';

  @override
  String musicMenu_removeThumbnailSuccess(Object name) {
    return 'Remove cover for \"$name\" is success';
  }

  @override
  String get musicMenu_changePlayerTheme => 'Change theme';

  @override
  String musicMenu_musicShown(Object name) {
    return '\"$name\" is displayed';
  }

  @override
  String musicMenu_musicHidden(Object name) {
    return '\"$name\" is hidden';
  }

  @override
  String get musicMenu_show => 'Display';

  @override
  String get musicMenu_hide => 'Hide';

  @override
  String get musicMenu_deleteOnDevice => 'Delete from Device';

  @override
  String musicMenu_playNextMessage(Object musicTitle) {
    return 'Next, the song \"$musicTitle\" wil be play';
  }

  @override
  String get musicMenu_error => 'Error';

  @override
  String get musicMenu_removeFromPlaylist => 'Remove from playlist';

  @override
  String musicMenu_removeFromPlaylistSuccess(Object musicTitle) {
    return '\"$musicTitle\" is removed';
  }

  @override
  String get musicMenu_notFoundLibrary => 'Library is not found';

  @override
  String musicMenu_musicPauseAfter(Object time) {
    return 'Turn off playing after $time';
  }

  @override
  String get musicMenu_turnOffSetStopTime => 'Timer off';

  @override
  String get libraryMenu_addItems => 'Add songs to library';

  @override
  String get libraryMenu_edit => 'Edit Information';

  @override
  String get libraryMenu_sortItems => 'Sort Songs';

  @override
  String get libraryMenu_downloadItemThumbnails => 'Download cover images for all Songs';

  @override
  String get libraryMenu_deleteLibrary => 'Delete Library';

  @override
  String get createLibraryTitle => 'Create Library';

  @override
  String get libraryName => 'Library Name';

  @override
  String get error_requiredName => 'Name cannot be empty';

  @override
  String get error_checkAgain => 'Please check the information again';

  @override
  String get error_existedName => 'Name is exists';

  @override
  String get searchPlaceholder => 'Search';

  @override
  String get searchNoResults => 'No Results';

  @override
  String get noData => 'No Data';

  @override
  String get formAction_confirm => 'Confirm';

  @override
  String get formAction_cancel => 'Cancel';

  @override
  String get detailTitle => 'Details';

  @override
  String get detail_title => 'Title';

  @override
  String get detail_album => 'Album';

  @override
  String get detail_artist => 'Artist';

  @override
  String get detail_genre => 'Genre';

  @override
  String get detail_length => 'Duration';

  @override
  String get detail_size => 'Size';

  @override
  String get detail_filePath => 'Location';

  @override
  String get detail_creationDate => 'Creation Date';

  @override
  String get detail_lastModificationDate => 'Last Modify';

  @override
  String get detail_empty => '<empty>';

  @override
  String get folderName => 'Folder name';

  @override
  String get sortByTitle => 'Sort By';

  @override
  String get sortField_musicName => 'Song Name';

  @override
  String get sortField_artist => 'Artist Name';

  @override
  String get sortField_length => 'Duration';

  @override
  String get sortField_newest => 'Newest';

  @override
  String get sortField_oldest => 'Oldest';

  @override
  String get sortDirectionTitle => 'Sort Order';

  @override
  String get sortDirection_ascending => 'Ascending (A ⇀ Z)';

  @override
  String get sortDirection_descending => 'Descending (Z ⇀ A)';

  @override
  String get playMusic => 'Play';

  @override
  String get playMusicRandom => 'Shuffle';

  @override
  String get favorites => 'Favorites';

  @override
  String get songTitle => 'Song';

  @override
  String get setStopTimeTitle => 'Sleep Timer';

  @override
  String get remainingTitle => 'Remaining';

  @override
  String get playlistTitle => 'Playlist';

  @override
  String nHours(num hour) {
    final intl.NumberFormat hourNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
      
    );
    final String hourString = hourNumberFormat.format(hour);

    String _temp0 = intl.Intl.pluralLogic(
      hour,
      locale: localeName,
      other: '$hourString hours',
      one: '1 hour',
      zero: 'zero hour',
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
      other: '$minuteString minutes',
      one: '1 minute',
      zero: 'zero minute',
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
      other: '$secondsString seconds',
      one: '1 second',
      zero: 'zero seconds',
    );
    return '$_temp0';
  }

  @override
  String get changePlayerThemeTitle => 'Player theme';

  @override
  String nSongs(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count songs',
      one: '1 song',
      zero: 'no songs',
    );
    return '$_temp0';
  }

  @override
  String home_tab(String id) {
    String _temp0 = intl.Intl.selectLogic(
      id,
      {
        'recommended': 'For you',
        'songs': 'Songs',
        'libraries': 'Libraries',
        'folders': 'Folders',
        'other': '',
      },
    );
    return '$_temp0';
  }

  @override
  String get message_addMusicToLibrarySuccess => 'This song is added to library';

  @override
  String get library_musicExists => ' (this song is existed)';

  @override
  String get deleteLibraryPopupTitle => 'Delete library';

  @override
  String deleteLibraryPopUpMessage(Object libraryTitle) {
    return 'Are you sure to delete \"$libraryTitle\"?';
  }

  @override
  String deleteLibrarySuccess(Object title) {
    return '\"$title\" is deleted';
  }

  @override
  String get status_saving => 'Saving...';

  @override
  String get status_completed => 'Completed!';

  @override
  String get status_waiting => 'Please wait...';

  @override
  String get status_loading => 'Loading...';

  @override
  String downloadThumbnail_progress(Object percent) {
    return 'Progress: $percent%';
  }

  @override
  String downloadThumbnail_totalCount(Object total) {
    return 'Total: $total';
  }

  @override
  String downloadThumbnail_existsCount(Object total) {
    return 'Already have (no download): $total';
  }

  @override
  String downloadThumbnail_successCount(Object total) {
    return 'Success: $total';
  }

  @override
  String downloadThumbnail_failedCount(Object total) {
    return 'Failure: $total';
  }

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get folderMenu_createLibraryDuplicatedMessage => 'The library already exists. Do you want to add all songs from this folder to the library with the same name?';

  @override
  String folderMenu_createLibrarySuccess(Object name) {
    return '\"$name\" library is created';
  }

  @override
  String get folderMenu_displayFolder => 'Display folder';

  @override
  String get folderMenu_hideFolder => 'Hide folder';

  @override
  String folderMenu_displayAllFiles(int totalHiddenFile) {
    String _temp0 = intl.Intl.pluralLogic(
      totalHiddenFile,
      locale: localeName,
      one: '1 file',
      zero: 'no files',
      other: '$totalHiddenFile files',
    );
    return 'Display all files ($_temp0)';
  }

  @override
  String get folderMenu_hideAllFiles => 'Hide all files';

  @override
  String get scanMusic => 'Scan files';

  @override
  String get scanMusic_scaning => 'Scanning for music files...';

  @override
  String get scanMusic_scanCompleted => 'Completed';

  @override
  String get scanMusic_noNewFile => 'no new files is founded';

  @override
  String scanMusic_nNewFiles(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      one: 'one song is',
      other: '$count songs are',
    );
    return '$_temp0 added';
  }

  @override
  String scanMusic_newDeletedFiles(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      one: '1 song is',
      other: '$count songs are',
    );
    return '$_temp0 removed because not found in device storage';
  }

  @override
  String get scanMusic_noPermission => 'No storage access permission to scan music. Please grant \"Manage all files\" permission.';

  @override
  String get hiddenFolder => 'Hidden folder';

  @override
  String nHiddenFiles(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      one: '1 hidden files',
      other: '$count hidden files',
    );
    return '$_temp0';
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
  String get and => 'and';

  @override
  String nBeHidden(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      one: 'is hidden',
      other: 'are hidden',
    );
    return '$_temp0';
  }

  @override
  String get viewHiddenFiles => 'Show hidden files';

  @override
  String get hideHiddenFiles => 'Not show hidden files';

  @override
  String get music_hidden => 'Hidden';

  @override
  String get music_unknownArtist => '<Unknown>';

  @override
  String nLibraries(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      one: '1 library',
      zero: 'no libraries',
      other: '$count libraries',
    );
    return '$_temp0';
  }

  @override
  String get noLibraries => 'No libraries!';

  @override
  String get createNew => 'Create new';

  @override
  String get removeAllFromFavorite => 'Remove all songs';

  @override
  String get removeAllFromFavoriteSuccess => 'All songs are removed from Favorites';

  @override
  String get emptyList => 'Empty list!';

  @override
  String get addSongsToLibrary => 'Add songs';

  @override
  String nLastDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      one: 'Last one day',
      other: 'Last $count days',
    );
    return '$_temp0';
  }

  @override
  String get libraryTitle => 'Library';

  @override
  String get folderTitle => 'Folder';

  @override
  String get allSongs => 'All songs';

  @override
  String get doneTitle => 'Done';

  @override
  String get selectAll => 'Select all';

  @override
  String get selected => 'Selected';

  @override
  String get displayedAllResult => 'All results are shown!';

  @override
  String get pictureProvidedByYoutube => 'Pictures are provided by Youtube';

  @override
  String get errorTryAgain => 'Error has occurred, please try again later!';

  @override
  String changeMusicThumbnailSuccess(Object title) {
    return 'Cover image for \"\$$title\" is updated';
  }

  @override
  String get themeIsUsed => 'Used';

  @override
  String get themeApply => 'Apply';

  @override
  String get auto => 'Auto';

  @override
  String get picture => 'Picture';

  @override
  String get blur => 'Blur';

  @override
  String get optionsTitle => 'Options';

  @override
  String get stopAfter => 'Stop after';

  @override
  String get createLibrary => 'Create a library';

  @override
  String get updateLibrary => 'Update a library';

  @override
  String get off => 'Off';

  @override
  String get playlist_shuffleSuccess => 'List is shuffled';

  @override
  String get playlist_removeAllItemsConfirmMessage => 'Delete all songs from playlist?';

  @override
  String get confirmDialog_defaultTitle => 'Confirm';

  @override
  String get confirmDialog_defaultMessage => 'Are you sure?';

  @override
  String get nowPlayingTitle => 'Now Playing';

  @override
  String get okTitle => 'OK';

  @override
  String notFoundFileName(Object name) {
    return 'File \"$name\" is not found';
  }
}

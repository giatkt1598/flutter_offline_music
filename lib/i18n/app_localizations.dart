import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'i18n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('vi')
  ];

  /// No description provided for @applicationName.
  ///
  /// In en, this message translates to:
  /// **'Music Player'**
  String get applicationName;

  /// No description provided for @languageTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageTitle;

  /// No description provided for @langOptionDisplayName.
  ///
  /// In en, this message translates to:
  /// **'{languageCode, select, vi{Tiếng Việt} en{English} other{System}}'**
  String langOptionDisplayName(String languageCode);

  /// No description provided for @settingTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingTitle;

  /// No description provided for @setting_playerTitle.
  ///
  /// In en, this message translates to:
  /// **'Music Player'**
  String get setting_playerTitle;

  /// No description provided for @setting_themeTitle.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get setting_themeTitle;

  /// No description provided for @theme_lightMode.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get theme_lightMode;

  /// No description provided for @theme_darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get theme_darkMode;

  /// No description provided for @theme_auto.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get theme_auto;

  /// No description provided for @settingPlayer_skipSilence.
  ///
  /// In en, this message translates to:
  /// **'Skip silence'**
  String get settingPlayer_skipSilence;

  /// No description provided for @settingPlayer_autoVolume.
  ///
  /// In en, this message translates to:
  /// **'Fade in/out when playing/pausing or switching tracks'**
  String get settingPlayer_autoVolume;

  /// No description provided for @settingPlayer_autoScan.
  ///
  /// In en, this message translates to:
  /// **'Auto scan files'**
  String get settingPlayer_autoScan;

  /// No description provided for @settingPlayer_background.
  ///
  /// In en, this message translates to:
  /// **'Background'**
  String get settingPlayer_background;

  /// No description provided for @setting_aboutTitle.
  ///
  /// In en, this message translates to:
  /// **'App Information'**
  String get setting_aboutTitle;

  /// No description provided for @about_intro.
  ///
  /// In en, this message translates to:
  /// **'Introduction'**
  String get about_intro;

  /// No description provided for @about_version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get about_version;

  /// No description provided for @about_contact.
  ///
  /// In en, this message translates to:
  /// **'Info & Support'**
  String get about_contact;

  /// No description provided for @setting_deleteDataPermanently.
  ///
  /// In en, this message translates to:
  /// **'Delete data'**
  String get setting_deleteDataPermanently;

  /// No description provided for @setting_deleteDataPermanentlyConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure to delete all data?. After deletion, you need to restart the app.'**
  String get setting_deleteDataPermanentlyConfirmMessage;

  /// No description provided for @setting_deleteDataPermanentlySuccess.
  ///
  /// In en, this message translates to:
  /// **'All data is deleted, please restart the application...'**
  String get setting_deleteDataPermanentlySuccess;

  /// No description provided for @dashboard_playingRecently.
  ///
  /// In en, this message translates to:
  /// **'Recently Played'**
  String get dashboard_playingRecently;

  /// No description provided for @dashboard_viewMore.
  ///
  /// In en, this message translates to:
  /// **'View more >'**
  String get dashboard_viewMore;

  /// No description provided for @dashboard_newFiles.
  ///
  /// In en, this message translates to:
  /// **'Recently Added'**
  String get dashboard_newFiles;

  /// No description provided for @dashboard_mostListening.
  ///
  /// In en, this message translates to:
  /// **'Most Listened'**
  String get dashboard_mostListening;

  /// No description provided for @dashboard_noSongsToPlay.
  ///
  /// In en, this message translates to:
  /// **'No songs to play'**
  String get dashboard_noSongsToPlay;

  /// No description provided for @musicMenu_play.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get musicMenu_play;

  /// No description provided for @musicMenu_playNext.
  ///
  /// In en, this message translates to:
  /// **'Play Next'**
  String get musicMenu_playNext;

  /// No description provided for @musicMenu_addToFavorite.
  ///
  /// In en, this message translates to:
  /// **'Add to favorites'**
  String get musicMenu_addToFavorite;

  /// No description provided for @musicMenu_addToFavoriteSuccess.
  ///
  /// In en, this message translates to:
  /// **'Add to favorites is success'**
  String get musicMenu_addToFavoriteSuccess;

  /// No description provided for @musicMenu_removeFromFavorite.
  ///
  /// In en, this message translates to:
  /// **'Remove from favorites'**
  String get musicMenu_removeFromFavorite;

  /// No description provided for @musicMenu_removeFromFavoriteSuccess.
  ///
  /// In en, this message translates to:
  /// **'Remove from favorites is success'**
  String get musicMenu_removeFromFavoriteSuccess;

  /// No description provided for @musicMenu_addToLibrary.
  ///
  /// In en, this message translates to:
  /// **'Add to library'**
  String get musicMenu_addToLibrary;

  /// No description provided for @musicMenu_removeFromLibrary.
  ///
  /// In en, this message translates to:
  /// **'Remove from library'**
  String get musicMenu_removeFromLibrary;

  /// No description provided for @musicMenu_removeFromLibrarySuccess.
  ///
  /// In en, this message translates to:
  /// **'\"{musicTitle}\" is removed'**
  String musicMenu_removeFromLibrarySuccess(Object musicTitle);

  /// No description provided for @musicMenu_setStopTime.
  ///
  /// In en, this message translates to:
  /// **'Sleep Timer'**
  String get musicMenu_setStopTime;

  /// No description provided for @musicMenu_changeThumbnail.
  ///
  /// In en, this message translates to:
  /// **'Change cover image'**
  String get musicMenu_changeThumbnail;

  /// No description provided for @musicMenu_removeThumbnail.
  ///
  /// In en, this message translates to:
  /// **'Remove cover image'**
  String get musicMenu_removeThumbnail;

  /// No description provided for @musicMenu_removeThumbnailSuccess.
  ///
  /// In en, this message translates to:
  /// **'Remove cover for \"{name}\" is success'**
  String musicMenu_removeThumbnailSuccess(Object name);

  /// No description provided for @musicMenu_changePlayerTheme.
  ///
  /// In en, this message translates to:
  /// **'Change theme'**
  String get musicMenu_changePlayerTheme;

  /// No description provided for @musicMenu_musicShown.
  ///
  /// In en, this message translates to:
  /// **'\"{name}\" is displayed'**
  String musicMenu_musicShown(Object name);

  /// No description provided for @musicMenu_musicHidden.
  ///
  /// In en, this message translates to:
  /// **'\"{name}\" is hidden'**
  String musicMenu_musicHidden(Object name);

  /// No description provided for @musicMenu_show.
  ///
  /// In en, this message translates to:
  /// **'Display'**
  String get musicMenu_show;

  /// No description provided for @musicMenu_hide.
  ///
  /// In en, this message translates to:
  /// **'Hide'**
  String get musicMenu_hide;

  /// No description provided for @musicMenu_deleteOnDevice.
  ///
  /// In en, this message translates to:
  /// **'Delete from Device'**
  String get musicMenu_deleteOnDevice;

  /// No description provided for @musicMenu_playNextMessage.
  ///
  /// In en, this message translates to:
  /// **'Next, the song \"{musicTitle}\" wil be play'**
  String musicMenu_playNextMessage(Object musicTitle);

  /// No description provided for @musicMenu_error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get musicMenu_error;

  /// No description provided for @musicMenu_removeFromPlaylist.
  ///
  /// In en, this message translates to:
  /// **'Remove from playlist'**
  String get musicMenu_removeFromPlaylist;

  /// No description provided for @musicMenu_removeFromPlaylistSuccess.
  ///
  /// In en, this message translates to:
  /// **'\"{musicTitle}\" is removed'**
  String musicMenu_removeFromPlaylistSuccess(Object musicTitle);

  /// No description provided for @musicMenu_notFoundLibrary.
  ///
  /// In en, this message translates to:
  /// **'Library is not found'**
  String get musicMenu_notFoundLibrary;

  /// No description provided for @musicMenu_musicPauseAfter.
  ///
  /// In en, this message translates to:
  /// **'Turn off playing after {time}'**
  String musicMenu_musicPauseAfter(Object time);

  /// No description provided for @musicMenu_turnOffSetStopTime.
  ///
  /// In en, this message translates to:
  /// **'Timer off'**
  String get musicMenu_turnOffSetStopTime;

  /// No description provided for @libraryMenu_addItems.
  ///
  /// In en, this message translates to:
  /// **'Add songs to library'**
  String get libraryMenu_addItems;

  /// No description provided for @libraryMenu_edit.
  ///
  /// In en, this message translates to:
  /// **'Edit Information'**
  String get libraryMenu_edit;

  /// No description provided for @libraryMenu_sortItems.
  ///
  /// In en, this message translates to:
  /// **'Sort Songs'**
  String get libraryMenu_sortItems;

  /// No description provided for @libraryMenu_downloadItemThumbnails.
  ///
  /// In en, this message translates to:
  /// **'Download cover images for all Songs'**
  String get libraryMenu_downloadItemThumbnails;

  /// No description provided for @libraryMenu_deleteLibrary.
  ///
  /// In en, this message translates to:
  /// **'Delete Library'**
  String get libraryMenu_deleteLibrary;

  /// No description provided for @createLibraryTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Library'**
  String get createLibraryTitle;

  /// No description provided for @libraryName.
  ///
  /// In en, this message translates to:
  /// **'Library Name'**
  String get libraryName;

  /// No description provided for @error_requiredName.
  ///
  /// In en, this message translates to:
  /// **'Name cannot be empty'**
  String get error_requiredName;

  /// No description provided for @error_checkAgain.
  ///
  /// In en, this message translates to:
  /// **'Please check the information again'**
  String get error_checkAgain;

  /// No description provided for @error_existedName.
  ///
  /// In en, this message translates to:
  /// **'Name is exists'**
  String get error_existedName;

  /// No description provided for @searchPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchPlaceholder;

  /// No description provided for @searchNoResults.
  ///
  /// In en, this message translates to:
  /// **'No Results'**
  String get searchNoResults;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No Data'**
  String get noData;

  /// No description provided for @formAction_confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get formAction_confirm;

  /// No description provided for @formAction_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get formAction_cancel;

  /// No description provided for @detailTitle.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get detailTitle;

  /// No description provided for @detail_title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get detail_title;

  /// No description provided for @detail_album.
  ///
  /// In en, this message translates to:
  /// **'Album'**
  String get detail_album;

  /// No description provided for @detail_artist.
  ///
  /// In en, this message translates to:
  /// **'Artist'**
  String get detail_artist;

  /// No description provided for @detail_genre.
  ///
  /// In en, this message translates to:
  /// **'Genre'**
  String get detail_genre;

  /// No description provided for @detail_length.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get detail_length;

  /// No description provided for @detail_size.
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get detail_size;

  /// No description provided for @detail_filePath.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get detail_filePath;

  /// No description provided for @detail_creationDate.
  ///
  /// In en, this message translates to:
  /// **'Creation Date'**
  String get detail_creationDate;

  /// No description provided for @detail_lastModificationDate.
  ///
  /// In en, this message translates to:
  /// **'Last Modify'**
  String get detail_lastModificationDate;

  /// No description provided for @detail_empty.
  ///
  /// In en, this message translates to:
  /// **'<empty>'**
  String get detail_empty;

  /// No description provided for @folderName.
  ///
  /// In en, this message translates to:
  /// **'Folder name'**
  String get folderName;

  /// No description provided for @sortByTitle.
  ///
  /// In en, this message translates to:
  /// **'Sort By'**
  String get sortByTitle;

  /// No description provided for @sortField_musicName.
  ///
  /// In en, this message translates to:
  /// **'Song Name'**
  String get sortField_musicName;

  /// No description provided for @sortField_artist.
  ///
  /// In en, this message translates to:
  /// **'Artist Name'**
  String get sortField_artist;

  /// No description provided for @sortField_length.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get sortField_length;

  /// No description provided for @sortField_newest.
  ///
  /// In en, this message translates to:
  /// **'Newest'**
  String get sortField_newest;

  /// No description provided for @sortField_oldest.
  ///
  /// In en, this message translates to:
  /// **'Oldest'**
  String get sortField_oldest;

  /// No description provided for @sortDirectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Sort Order'**
  String get sortDirectionTitle;

  /// No description provided for @sortDirection_ascending.
  ///
  /// In en, this message translates to:
  /// **'Ascending (A ⇀ Z)'**
  String get sortDirection_ascending;

  /// No description provided for @sortDirection_descending.
  ///
  /// In en, this message translates to:
  /// **'Descending (Z ⇀ A)'**
  String get sortDirection_descending;

  /// No description provided for @playMusic.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get playMusic;

  /// No description provided for @playMusicRandom.
  ///
  /// In en, this message translates to:
  /// **'Shuffle'**
  String get playMusicRandom;

  /// No description provided for @favorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// No description provided for @songTitle.
  ///
  /// In en, this message translates to:
  /// **'Song'**
  String get songTitle;

  /// No description provided for @setStopTimeTitle.
  ///
  /// In en, this message translates to:
  /// **'Sleep Timer'**
  String get setStopTimeTitle;

  /// No description provided for @remainingTitle.
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get remainingTitle;

  /// No description provided for @playlistTitle.
  ///
  /// In en, this message translates to:
  /// **'Playlist'**
  String get playlistTitle;

  /// No description provided for @nHours.
  ///
  /// In en, this message translates to:
  /// **'{hour, plural, =0{zero hour} =1{1 hour} other{{hour} hours}}'**
  String nHours(num hour);

  /// No description provided for @nMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minute, plural, =0{zero minute} =1{1 minute} other{{minute} minutes}}'**
  String nMinutes(num minute);

  /// No description provided for @nSeconds.
  ///
  /// In en, this message translates to:
  /// **'{seconds, plural, =0{zero seconds} =1{1 second} other{{seconds} seconds}}'**
  String nSeconds(num seconds);

  /// No description provided for @changePlayerThemeTitle.
  ///
  /// In en, this message translates to:
  /// **'Player theme'**
  String get changePlayerThemeTitle;

  /// No description provided for @nSongs.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{no songs} =1{1 song} other{{count} songs}}'**
  String nSongs(int count);

  /// No description provided for @home_tab.
  ///
  /// In en, this message translates to:
  /// **'{id, select, recommended{For you} songs{Songs} libraries{Libraries} folders{Folders} other{}}'**
  String home_tab(String id);

  /// No description provided for @message_addMusicToLibrarySuccess.
  ///
  /// In en, this message translates to:
  /// **'This song is added to library'**
  String get message_addMusicToLibrarySuccess;

  /// No description provided for @library_musicExists.
  ///
  /// In en, this message translates to:
  /// **' (this song is existed)'**
  String get library_musicExists;

  /// No description provided for @deleteLibraryPopupTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete library'**
  String get deleteLibraryPopupTitle;

  /// No description provided for @deleteLibraryPopUpMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure to delete \"{libraryTitle}\"?'**
  String deleteLibraryPopUpMessage(Object libraryTitle);

  /// No description provided for @deleteLibrarySuccess.
  ///
  /// In en, this message translates to:
  /// **'\"{title}\" is deleted'**
  String deleteLibrarySuccess(Object title);

  /// No description provided for @status_saving.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get status_saving;

  /// No description provided for @status_completed.
  ///
  /// In en, this message translates to:
  /// **'Completed!'**
  String get status_completed;

  /// No description provided for @status_waiting.
  ///
  /// In en, this message translates to:
  /// **'Please wait...'**
  String get status_waiting;

  /// No description provided for @status_loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get status_loading;

  /// No description provided for @downloadThumbnail_progress.
  ///
  /// In en, this message translates to:
  /// **'Progress: {percent}%'**
  String downloadThumbnail_progress(Object percent);

  /// No description provided for @downloadThumbnail_totalCount.
  ///
  /// In en, this message translates to:
  /// **'Total: {total}'**
  String downloadThumbnail_totalCount(Object total);

  /// No description provided for @downloadThumbnail_existsCount.
  ///
  /// In en, this message translates to:
  /// **'Already have (no download): {total}'**
  String downloadThumbnail_existsCount(Object total);

  /// No description provided for @downloadThumbnail_successCount.
  ///
  /// In en, this message translates to:
  /// **'Success: {total}'**
  String downloadThumbnail_successCount(Object total);

  /// No description provided for @downloadThumbnail_failedCount.
  ///
  /// In en, this message translates to:
  /// **'Failure: {total}'**
  String downloadThumbnail_failedCount(Object total);

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @folderMenu_createLibraryDuplicatedMessage.
  ///
  /// In en, this message translates to:
  /// **'The library already exists. Do you want to add all songs from this folder to the library with the same name?'**
  String get folderMenu_createLibraryDuplicatedMessage;

  /// No description provided for @folderMenu_createLibrarySuccess.
  ///
  /// In en, this message translates to:
  /// **'\"{name}\" library is created'**
  String folderMenu_createLibrarySuccess(Object name);

  /// No description provided for @folderMenu_displayFolder.
  ///
  /// In en, this message translates to:
  /// **'Display folder'**
  String get folderMenu_displayFolder;

  /// No description provided for @folderMenu_hideFolder.
  ///
  /// In en, this message translates to:
  /// **'Hide folder'**
  String get folderMenu_hideFolder;

  /// No description provided for @folderMenu_displayAllFiles.
  ///
  /// In en, this message translates to:
  /// **'Display all files ({totalHiddenFile, plural, other{{totalHiddenFile} files} zero{no files} one{1 file}})'**
  String folderMenu_displayAllFiles(int totalHiddenFile);

  /// No description provided for @folderMenu_hideAllFiles.
  ///
  /// In en, this message translates to:
  /// **'Hide all files'**
  String get folderMenu_hideAllFiles;

  /// No description provided for @scanMusic.
  ///
  /// In en, this message translates to:
  /// **'Scan files'**
  String get scanMusic;

  /// No description provided for @scanMusic_scaning.
  ///
  /// In en, this message translates to:
  /// **'Scanning for music files...'**
  String get scanMusic_scaning;

  /// No description provided for @scanMusic_scanCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get scanMusic_scanCompleted;

  /// No description provided for @scanMusic_noNewFile.
  ///
  /// In en, this message translates to:
  /// **'no new files is founded'**
  String get scanMusic_noNewFile;

  /// No description provided for @scanMusic_nNewFiles.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, other{{count} songs are} one{one song is}} added'**
  String scanMusic_nNewFiles(int count);

  /// No description provided for @scanMusic_newDeletedFiles.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, other{{count} songs are} one{1 song is}} removed because not found in device storage'**
  String scanMusic_newDeletedFiles(int count);

  /// No description provided for @scanMusic_noPermission.
  ///
  /// In en, this message translates to:
  /// **'No storage access permission to scan music. Please grant \"Manage all files\" permission.'**
  String get scanMusic_noPermission;

  /// No description provided for @hiddenFolder.
  ///
  /// In en, this message translates to:
  /// **'Hidden folder'**
  String get hiddenFolder;

  /// No description provided for @nHiddenFiles.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, other{{count} hidden files} one{1 hidden files}}'**
  String nHiddenFiles(int count);

  /// No description provided for @nFolders.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, other{{count} folders} one{1 folder}}'**
  String nFolders(int count);

  /// No description provided for @nFiles.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, other{{count} files} one{1 file}}'**
  String nFiles(int count);

  /// No description provided for @and.
  ///
  /// In en, this message translates to:
  /// **'and'**
  String get and;

  /// nBeHidden
  ///
  /// In en, this message translates to:
  /// **'{count, plural, other{are hidden} one{is hidden}}'**
  String nBeHidden(int count);

  /// No description provided for @viewHiddenFiles.
  ///
  /// In en, this message translates to:
  /// **'Show hidden files'**
  String get viewHiddenFiles;

  /// No description provided for @hideHiddenFiles.
  ///
  /// In en, this message translates to:
  /// **'Not show hidden files'**
  String get hideHiddenFiles;

  /// No description provided for @music_hidden.
  ///
  /// In en, this message translates to:
  /// **'Hidden'**
  String get music_hidden;

  /// No description provided for @music_unknownArtist.
  ///
  /// In en, this message translates to:
  /// **'<Unknown>'**
  String get music_unknownArtist;

  /// No description provided for @nLibraries.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, other{{count} libraries} zero{no libraries} one{1 library}}'**
  String nLibraries(int count);

  /// No description provided for @noLibraries.
  ///
  /// In en, this message translates to:
  /// **'No libraries!'**
  String get noLibraries;

  /// No description provided for @createNew.
  ///
  /// In en, this message translates to:
  /// **'Create new'**
  String get createNew;

  /// No description provided for @removeAllFromFavorite.
  ///
  /// In en, this message translates to:
  /// **'Remove all songs'**
  String get removeAllFromFavorite;

  /// No description provided for @removeAllFromFavoriteSuccess.
  ///
  /// In en, this message translates to:
  /// **'All songs are removed from Favorites'**
  String get removeAllFromFavoriteSuccess;

  /// No description provided for @emptyList.
  ///
  /// In en, this message translates to:
  /// **'Empty list!'**
  String get emptyList;

  /// No description provided for @addSongsToLibrary.
  ///
  /// In en, this message translates to:
  /// **'Add songs'**
  String get addSongsToLibrary;

  /// No description provided for @nLastDays.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, other{Last {count} days} one{Last one day}}'**
  String nLastDays(int count);

  /// No description provided for @libraryTitle.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get libraryTitle;

  /// No description provided for @folderTitle.
  ///
  /// In en, this message translates to:
  /// **'Folder'**
  String get folderTitle;

  /// No description provided for @allSongs.
  ///
  /// In en, this message translates to:
  /// **'All songs'**
  String get allSongs;

  /// No description provided for @doneTitle.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get doneTitle;

  /// No description provided for @selectAll.
  ///
  /// In en, this message translates to:
  /// **'Select all'**
  String get selectAll;

  /// No description provided for @selected.
  ///
  /// In en, this message translates to:
  /// **'Selected'**
  String get selected;

  /// No description provided for @displayedAllResult.
  ///
  /// In en, this message translates to:
  /// **'All results are shown!'**
  String get displayedAllResult;

  /// No description provided for @pictureProvidedByYoutube.
  ///
  /// In en, this message translates to:
  /// **'Pictures are provided by Youtube'**
  String get pictureProvidedByYoutube;

  /// No description provided for @errorTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Error has occurred, please try again later!'**
  String get errorTryAgain;

  /// No description provided for @changeMusicThumbnailSuccess.
  ///
  /// In en, this message translates to:
  /// **'Cover image for \"\${title}\" is updated'**
  String changeMusicThumbnailSuccess(Object title);

  /// No description provided for @themeIsUsed.
  ///
  /// In en, this message translates to:
  /// **'Used'**
  String get themeIsUsed;

  /// No description provided for @themeApply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get themeApply;

  /// No description provided for @auto.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get auto;

  /// No description provided for @picture.
  ///
  /// In en, this message translates to:
  /// **'Picture'**
  String get picture;

  /// No description provided for @blur.
  ///
  /// In en, this message translates to:
  /// **'Blur'**
  String get blur;

  /// No description provided for @optionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Options'**
  String get optionsTitle;

  /// No description provided for @stopAfter.
  ///
  /// In en, this message translates to:
  /// **'Stop after'**
  String get stopAfter;

  /// No description provided for @createLibrary.
  ///
  /// In en, this message translates to:
  /// **'Create a library'**
  String get createLibrary;

  /// No description provided for @updateLibrary.
  ///
  /// In en, this message translates to:
  /// **'Update a library'**
  String get updateLibrary;

  /// No description provided for @off.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get off;

  /// No description provided for @playlist_shuffleSuccess.
  ///
  /// In en, this message translates to:
  /// **'List is shuffled'**
  String get playlist_shuffleSuccess;

  /// No description provided for @playlist_removeAllItemsConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Delete all songs from playlist?'**
  String get playlist_removeAllItemsConfirmMessage;

  /// No description provided for @confirmDialog_defaultTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirmDialog_defaultTitle;

  /// No description provided for @confirmDialog_defaultMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure?'**
  String get confirmDialog_defaultMessage;

  /// No description provided for @nowPlayingTitle.
  ///
  /// In en, this message translates to:
  /// **'Now Playing'**
  String get nowPlayingTitle;

  /// No description provided for @okTitle.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get okTitle;

  /// No description provided for @notFoundFileName.
  ///
  /// In en, this message translates to:
  /// **'File \"{name}\" is not found'**
  String notFoundFileName(Object name);
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'vi': return AppLocalizationsVi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}

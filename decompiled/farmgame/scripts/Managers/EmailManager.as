package Managers
{
   import Classes.util.FacebookSocialNetwork;
   import Classes.util.FarmFacebookSocialNetwork;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.EmailIconPopup;
   import Display.EmailPopup;
   import Display.GenericIconPopup;
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Events.EmailPopupEvent;
   import Transactions.TGrantEmailPermission;
   import Transactions.TRevokeEmailPermission;
   import Transactions.TSeenRequestEmail;
   import Transactions.TSeenRevampEmail;
   import Transactions.TSeenRevampLockedboxEmail;
   import Transactions.TSeenRevampProxyEmail;
   import Transactions.TSendEmailPasscode;
   
   public class EmailManager
   {
      
      private static var m_objInstance:EmailManager;
      
      public static const NUMBER_OF_DAYS_BEFORE_EMAIL_POP:int = 30;
      
      public static const FEATURE_FLASH_CAN_ASK_EMAIL:String = "FEATURE_FLASH_CAN_ASK_EMAIL";
      
      public function EmailManager(objEnforcer:SingletonEnforcer)
      {
         super();
      }
      
      public static function getInstance() : EmailManager
      {
         if(m_objInstance == null)
         {
            m_objInstance = new EmailManager(new SingletonEnforcer());
         }
         return m_objInstance;
      }
      
      private static function prepareForDisplayEmailPermissionPrompt(permissionRequestSource:Number = 0) : Object
      {
         var result:Object = new Object();
         result["promptMessage"] = ZLocUtils.t("Dialogs","EmailPermission_Description");
         result["promptType"] = GenericPopup.TYPE_ACCEPTCANCEL;
         result["canRequestEmailPermission"] = true;
         result["showEmailPopupImmediately"] = true;
         result["statCategory"] = "defaultPrompt";
         result["featureCalloutIconAsset"] = Global.getAssetURL(EmailIconPopup.EMAIL_ICON_ASSET);
         result["featureCalloutPopupAsset"] = GenericIconPopup.GENERIC_CALLOUT_ASSET;
         result["emailGenericText1"] = ZLocUtils.t("Dialogs","EmailPermission_Prompt_Revamp_TF1");
         result["emailGenericText2"] = ZLocUtils.t("Dialogs","EmailPermission_Prompt_Revamp_TF2");
         result["emailGenericText3"] = ZLocUtils.t("Dialogs","EmailPermission_Prompt_Revamp_TF3");
         result["emailGenericText4"] = ZLocUtils.t("Dialogs","EmailPermission_Prompt_Revamp_TF4");
         result["emailLegalText"] = "";
         result["buttonText"] = ZLocUtils.t("Dialogs","Update");
         var currentTimeNumber:Number = GlobalEngine.getTimer();
         var currentTime:Number = GlobalEngine.serverTime / 1000;
         var lastTimePopupWasShown:Number = Global.player.getFeatureLastShown(EmailIconPopup.EMAIL_LAST_SHOWN_STRING);
         var blockPopUpBecauseOfDayDelay:Boolean = false;
         var forcePopUpBecauseOfDelayTimeOut:Boolean = false;
         var numberOfSecondsInDayDelay:int = NUMBER_OF_DAYS_BEFORE_EMAIL_POP * FarmGameUtil.NUM_SECS_IN_DAY;
         if(currentTime < lastTimePopupWasShown + numberOfSecondsInDayDelay)
         {
            blockPopUpBecauseOfDayDelay = true;
         }
         else
         {
            forcePopUpBecauseOfDelayTimeOut = true;
         }
         if(blockPopUpBecauseOfDayDelay)
         {
            result["canRequestEmailPermission"] = false;
         }
         else if(forcePopUpBecauseOfDelayTimeOut)
         {
            result["canRequestEmailPermission"] = true;
         }
         switch(permissionRequestSource)
         {
            case EmailPopup.EMAIL_REVAMPED_VERBIAGE_USER:
               result["promptMessage"] = "revamped";
               result["promptType"] = GenericPopup.TYPE_OK;
               result["buttonText"] = ZLocUtils.t("Dialogs","Okay");
               result["statCategory"] = "revampedUserPrompts";
               result["featureCalloutIconAsset"] = Global.getAssetURL("assets/decorations/deco_pigeon_icon.png");
               result["featureCalloutPopupAsset"] = EmailIconPopup.EMAIL_PROMPT_ASSET;
               if(Global.player.seenRevampEmail >= Global.farmGameSettingsManager.getInt("maxTimesSeenEmailPermissionRevamp",2))
               {
                  result["canRequestEmailPermission"] = false;
               }
               if(int(currentTimeNumber / 1000) - Global.player.timeLastSeenRevampEmail <= Global.farmGameSettingsManager.getInt("minTimeBetweenEmailPermissionRevamp",172800))
               {
                  result["canRequestEmailPermission"] = false;
               }
               break;
            case EmailPopup.EMAIL_PROXY_USER:
               result["promptMessage"] = ZLocUtils.t("Dialogs","EmailPermission_Prompt_Revamp_Proxy");
               result["promptType"] = GenericPopup.TYPE_OK;
               result["featureCalloutPopupAsset"] = EmailIconPopup.EMAIL_PROMPT_ASSET;
               result["emailGenericText1"] = ZLocUtils.t("Dialogs","EmailPermission_Prompt_Revamp_Proxy_TF1");
               result["emailGenericText2"] = "";
               result["emailGenericText3"] = ZLocUtils.t("Dialogs","EmailPermission_Prompt_Revamp_Proxy_TF2");
               result["emailGenericText4"] = ZLocUtils.t("Dialogs","EmailPermission_Prompt_Revamp_Proxy_TF4");
               result["statCategory"] = "proxyUserPrompts";
               if(Global.player.seenRevampProxyEmail >= Global.farmGameSettingsManager.getInt("maxTimesSeenEmailPermissionRevampProxy",2))
               {
                  result["canRequestEmailPermission"] = false;
               }
               if(int(currentTimeNumber / 1000) - Global.player.timeLastSeenRevampProxyEmail <= Global.farmGameSettingsManager.getInt("minTimeBetweenEmailPermissionRevampProxy",172800))
               {
                  result["canRequestEmailPermission"] = false;
               }
               break;
            case EmailPopup.EMAIL_PROXY_LOCKED_BOX_USER:
               result["promptMessage"] = ZLocUtils.t("Dialogs","EmailPermission_Prompt_Revamp_Lockedbox");
               result["promptType"] = GenericPopup.TYPE_OK;
               result["featureCalloutPopupAsset"] = EmailIconPopup.EMAIL_PROMPT_ASSET;
               result["emailGenericText1"] = ZLocUtils.t("Dialogs","EmailPermission_Prompt_Revamp_Lockedbox_TF1");
               result["emailGenericText2"] = "";
               result["emailGenericText3"] = ZLocUtils.t("Dialogs","EmailPermission_Prompt_Revamp_Lockedbox_TF2");
               result["emailGenericText4"] = ZLocUtils.t("Dialogs","EmailPermission_Prompt_Revamp_Lockedbox_TF4");
               result["statCategory"] = "proxyLockedboxUserPrompts";
               result["featureCalloutIconAsset"] = Global.getAssetURL("assets/decorations/deco_lockedbox_icon.png");
               if(Global.player.seenRevampLockedboxEmail >= Global.farmGameSettingsManager.getInt("maxTimesSeenEmailPermissionRevampLockedbox",2))
               {
                  result["canRequestEmailPermission"] = false;
               }
               if(int(currentTimeNumber / 1000) - Global.player.timeLastSeenRevampLockedboxEmail <= Global.farmGameSettingsManager.getInt("minTimeBetweenEmailPermissionRevampLockedbox",172800))
               {
                  result["canRequestEmailPermission"] = false;
               }
               break;
            case EmailPopup.EMAIL_SOCIAL_COMM_USER:
               result["promptMessage"] = ZLocUtils.t("Dialogs","EmailPermission_Description_CommentBox_Checkbox");
               result["statCategory"] = "commentBoxPrompts_emailCheckBox";
               break;
            case EmailPopup.EMAIL_COMMENT_BOX_VARIANT_SOFTGATE:
               result["promptMessage"] = ZLocUtils.t("Dialogs","EmailPermission_Description_CommentBox" + MessageManager.COMMENT_BOX_EMAIL_VARIANT_SOFTGATE);
               result["statCategory"] = "commentBoxPrompts_" + MessageManager.COMMENT_BOX_EMAIL_VARIANT_SOFTGATE;
               break;
            case EmailPopup.EMAIL_PROMO_BAR:
               result["statCategory"] = "promoBarPrompts";
               break;
            case EmailPopup.EMAIL_HUD_ICON:
               result["statCategory"] = "hudIconPrompts";
               break;
            case EmailPopup.EMAIL_MARKET:
               result["statCategory"] = "marketPrompts";
               break;
            case EmailPopup.EMAIL_PROACTIVE_USER:
               result["statCategory"] = "proactivePrompts";
               if(Global.player.timesSeenRequestEmail < Global.farmGameSettingsManager.getInt("maxTimesSeenEmailPermissionRequest",3))
               {
                  result["canRequestEmailPermission"] = false;
               }
               if(Global.player.hoursSinceLastSeenRequestEmail > Global.farmGameSettingsManager.getInt("minHoursBetweenEmailPermissionRequests",24))
               {
                  result["canRequestEmailPermission"] = false;
               }
               break;
            case EmailPopup.EMAIL_LOCKED_BOX_RETRY:
               result["promptMessage"] = ZLocUtils.t("Dialogs","LockedBoxSignUpCode");
               result["statCategory"] = "lockBoxRetryPrompts";
               result["featureCalloutIconAsset"] = Global.getAssetURL("assets/decorations/deco_lockedbox_icon.png");
               break;
            case EmailPopup.EMAIL_LOCKED_BOX:
               result["promptMessage"] = ZLocUtils.t("Dialogs","LockedBoxSignUpEmail");
               result["statCategory"] = "lockBoxPrompts";
               result["featureCalloutIconAsset"] = Global.getAssetURL("assets/decorations/deco_lockedbox_icon.png");
               break;
            case EmailPopup.EMAIL_EXISTING_USER:
               result["statCategory"] = "existingUserPrompts";
               if(Global.player.timesSeenRequestEmail < Global.farmGameSettingsManager.getInt("maxTimesSeenEmailPermissionRequest",3))
               {
                  result["canRequestEmailPermission"] = false;
               }
               if(Global.player.hoursSinceLastSeenRequestEmail > Global.farmGameSettingsManager.getInt("minHoursBetweenEmailPermissionRequests",24))
               {
                  result["canRequestEmailPermission"] = false;
               }
               break;
            case EmailPopup.EMAIL_NEW_USER:
               result["statCategory"] = "newUserPrompts";
               if(Global.player.timesSeenRequestEmail < Global.farmGameSettingsManager.getInt("maxTimesSeenEmailPermissionRequest",3))
               {
                  result["canRequestEmailPermission"] = false;
               }
               if(Global.player.hoursSinceLastSeenRequestEmail > Global.farmGameSettingsManager.getInt("minHoursBetweenEmailPermissionRequests",24))
               {
                  result["canRequestEmailPermission"] = false;
               }
               break;
            case EmailPopup.EMAIL_NEW_USER_START_TUTORIAL_COIN:
               result["statCategory"] = "newUserStartTutorialPrompts";
               result["promptMessage"] = ZLocUtils.t("Dialogs","EmailPermission_Description_StartTutorialCoin");
               result["featureCalloutIconAsset"] = Global.getAssetURL("assets/consumables/consume_coins_icon.png");
               break;
            case EmailPopup.EMAIL_NEW_USER_START_TUTORIAL_COW:
               result["statCategory"] = "newUserStartTutorialPrompts";
               result["promptMessage"] = ZLocUtils.t("Dialogs","EmailPermission_Description_StartTutorialCow");
               result["featureCalloutIconAsset"] = Global.getAssetURL("assets/animals/animal_cow_icon.png");
               break;
            case EmailPopup.EMAIL_WILD_MUSTANG:
               result["promptMessage"] = ZLocUtils.t("Dialogs","EmailPermission_Description_Wild_Mustang");
               result["statCategory"] = "wildMustangPrompts";
               result["featureCalloutIconAsset"] = Global.getAssetURL("assets/animals/animal_mustang_icon.png");
               break;
            case EmailPopup.EMAIL_REACTIVATION:
               result["promptMessage"] = ZLocUtils.t("Dialogs","ReactivationVisitHasNotGivenEmailFree");
               result["statCategory"] = "reactivation";
         }
         return result;
      }
      
      public static function displayEmailPermissionPrompt(permissionRequestSource:Number = 0, onFinishPermissionsCallback:Function = null) : void
      {
         var parameters:Object = null;
         var emailRuntimeEnabled:Number = GlobalEngine.getFlashVar(FEATURE_FLASH_CAN_ASK_EMAIL) as Number;
         if(emailRuntimeEnabled > 0 && Global.player.canRequestEmailPermission && !GlobalEngine.socialNetwork.userHasEmailPermission() && !Global.player.isAutomatedQA)
         {
            parameters = prepareForDisplayEmailPermissionPrompt(permissionRequestSource);
            if(parameters["canRequestEmailPermission"])
            {
               FarmStatsManager.count("emailPermission","allow_email",parameters["statCategory"]);
               UI.displayPopup(new EmailIconPopup(parameters["promptMessage"],parameters["promptType"],onEmailPermissionPromptClosed,parameters["featureCalloutIconAsset"],permissionRequestSource,onFinishPermissionsCallback,false,true,"",true,parameters["featureCalloutPopupAsset"],parameters["emailGenericText1"],parameters["emailGenericText2"],parameters["emailGenericText3"],parameters["emailGenericText4"],parameters["emailLegalText"],parameters["buttonText"]),true,"emailPermissionPromptPopup");
            }
         }
      }
      
      protected static function onEmailPermissionPromptClosed(event:EmailPopupEvent) : void
      {
         var statCategory:String = "defaultPrompt";
         var shouldUpdateSeenFlags:Boolean = false;
         var shouldRevokeEmailPermission:Boolean = false;
         switch(event.permissionSource)
         {
            case EmailPopup.EMAIL_REVAMPED_VERBIAGE_USER:
               statCategory = "allowRevampedUserPromptsFV";
               seenRevampEmailPrompt();
               break;
            case EmailPopup.EMAIL_PROXY_USER:
               statCategory = "allowProxyUserPromptsFV";
               shouldRevokeEmailPermission = true;
               seenRevampProxyEmailPrompt();
               break;
            case EmailPopup.EMAIL_PROXY_LOCKED_BOX_USER:
               statCategory = "allowProxyLockedboxUserPromptsFV";
               shouldRevokeEmailPermission = true;
               seenRevampLockedboxEmailPrompt();
               break;
            case EmailPopup.EMAIL_SOCIAL_COMM_USER:
               statCategory = "allowCommentBoxPromptsFV_emailCheckbox";
               break;
            case EmailPopup.EMAIL_COMMENT_BOX_VARIANT_SOFTGATE:
               statCategory = "allowCommentBoxPromptsFV_" + MessageManager.COMMENT_BOX_EMAIL_VARIANT_SOFTGATE;
               break;
            case EmailPopup.EMAIL_PROMO_BAR:
               statCategory = "allowPromoBarPromptsFV";
               break;
            case EmailPopup.EMAIL_HUD_ICON:
               statCategory = "allowHudIconPromptsFV";
               break;
            case EmailPopup.EMAIL_MARKET:
               statCategory = "allowMarketPromptsFV";
               break;
            case EmailPopup.EMAIL_PROACTIVE_USER:
               statCategory = "allowProactivePromptsFV";
               break;
            case EmailPopup.EMAIL_LOCKED_BOX_RETRY:
               statCategory = "allowLockBoxRetryPromptsFV";
               break;
            case EmailPopup.EMAIL_LOCKED_BOX:
               statCategory = "allowLockBoxPromptsFV";
               break;
            case EmailPopup.EMAIL_EXISTING_USER:
               statCategory = "allowExistingUserPromptsFV";
               seenRequestEmailPrompt();
               break;
            case EmailPopup.EMAIL_NEW_USER:
               statCategory = "allowNewUserPromptsFV";
               seenRequestEmailPrompt();
               break;
            case EmailPopup.EMAIL_NEW_USER_START_TUTORIAL_COIN:
               statCategory = "allowNewUserStartTutorialCoinPromptsFV";
               seenRequestEmailPrompt();
               break;
            case EmailPopup.EMAIL_NEW_USER_START_TUTORIAL_COW:
               statCategory = "allowNewUserStartTutorialCowPromptsFV";
               seenRequestEmailPrompt();
               break;
            case EmailPopup.EMAIL_WILD_MUSTANG:
               statCategory = "allowWildMustangPromptsFV";
               seenRequestEmailPrompt();
               break;
            case EmailPopup.EMAIL_REACTIVATION:
               statCategory = "reactivation";
               seenRequestEmailPrompt();
               break;
            default:
               seenRequestEmailPrompt();
         }
         if(event.button == GenericPopup.OK || event.button == GenericPopup.ACCEPT)
         {
            if(shouldRevokeEmailPermission)
            {
               TransactionManager.addTransaction(new TRevokeEmailPermission(event.finishEmailPermissionsCallback,event.permissionSource,statCategory),true);
            }
            else
            {
               (GlobalEngine.socialNetwork as FacebookSocialNetwork).showEmailPermissionWithSource(event.finishEmailPermissionsCallback,event.permissionSource);
               FarmStatsManager.count("emailPermission","allow_email",statCategory);
            }
         }
      }
      
      protected static function seenRequestEmailPrompt() : void
      {
         var seenRequestEmailDialog:int = Global.player.timesSeenRequestEmail;
         seenRequestEmailDialog++;
         Global.player.seenRequestEmail = seenRequestEmailDialog;
         var hourSeenRequestEmailDialog:int = GlobalEngine.serverTime / 1000 / 60 / 60;
         Global.player.hourLastSeenRequestEmail = hourSeenRequestEmailDialog;
         TransactionManager.addTransaction(new TSeenRequestEmail());
      }
      
      protected static function seenRevampEmailPrompt() : void
      {
         var seenRevampEmailDialog:int = Global.player.seenRevampEmail;
         seenRevampEmailDialog++;
         Global.player.seenRevampEmail = seenRevampEmailDialog;
         var timeSeenRevampEmailDialog:int = GlobalEngine.serverTime;
         Global.player.timeLastSeenRevampEmail = timeSeenRevampEmailDialog;
         TransactionManager.addTransaction(new TSeenRevampEmail(),true);
      }
      
      protected static function seenRevampProxyEmailPrompt() : void
      {
         var seenRevampProxyEmailDialog:int = Global.player.seenRevampProxyEmail;
         seenRevampProxyEmailDialog++;
         Global.player.seenRevampProxyEmail = seenRevampProxyEmailDialog;
         var timeSeenRevampProxyEmailDialog:int = GlobalEngine.serverTime;
         Global.player.timeLastSeenRevampProxyEmail = timeSeenRevampProxyEmailDialog;
         TransactionManager.addTransaction(new TSeenRevampProxyEmail(),true);
      }
      
      protected static function seenRevampLockedboxEmailPrompt() : void
      {
         var seenRevampLockedboxEmailDialog:int = Global.player.seenRevampLockedboxEmail;
         seenRevampLockedboxEmailDialog++;
         Global.player.seenRevampLockedboxEmail = seenRevampLockedboxEmailDialog;
         var timeSeenRevampLockedboxEmailDialog:int = GlobalEngine.serverTime;
         Global.player.timeLastSeenRevampLockedboxEmail = timeSeenRevampLockedboxEmailDialog;
         TransactionManager.addTransaction(new TSeenRevampLockedboxEmail(),true);
      }
      
      public static function emailPermissionDialogClosed(userAccepted:Boolean, permissionRequestSource:Number) : void
      {
         switch(permissionRequestSource)
         {
            case EmailPopup.EMAIL_REVAMPED_VERBIAGE_USER:
               FarmStatsManager.count("emailPermission","allow_email","allowRevampedUserPromptsFB");
               break;
            case EmailPopup.EMAIL_PROXY_USER:
               FarmStatsManager.count("emailPermission","allow_email","allowProxyUserPromptsFB");
               break;
            case EmailPopup.EMAIL_PROXY_LOCKED_BOX_USER:
               FarmStatsManager.count("emailPermission","allow_email","allowProxyLockedboxUserPromptsFB");
               break;
            case EmailPopup.EMAIL_COMMENT_BOX_VARIANT_SOFTGATE:
               FarmStatsManager.count("emailPermission","allow_email","allowCommentBoxPromptsFB_" + MessageManager.COMMENT_BOX_EMAIL_VARIANT_SOFTGATE);
               break;
            case EmailPopup.EMAIL_SOCIAL_COMM_USER:
               FarmStatsManager.count("emailPermission","allow_email","allowCommentBoxPromptsFB_checkbox");
               break;
            case EmailPopup.EMAIL_NEW_USER_START_TUTORIAL_COW:
               FarmStatsManager.count("emailPermission","allow_email","allowNewUserCowPromptsFB");
               break;
            case EmailPopup.EMAIL_NEW_USER_START_TUTORIAL_COIN:
               FarmStatsManager.count("emailPermission","allow_email","allowNewUserCoinPromptsFB");
               break;
            case EmailPopup.EMAIL_PROMO_BAR:
               FarmStatsManager.count("emailPermission","allow_email","allowPromoBarUserPromptsFB");
               break;
            case EmailPopup.EMAIL_HUD_ICON:
               FarmStatsManager.count("emailPermission","allow_email","allowHudIconUserPromptsFB");
               break;
            case EmailPopup.EMAIL_MARKET:
               FarmStatsManager.count("emailPermission","allow_email","allowMarketUserPromptsFB");
               break;
            case EmailPopup.EMAIL_PROACTIVE_USER:
               FarmStatsManager.count("emailPermission","allow_email","allowProactiveUserPromptsFB");
               break;
            case EmailPopup.EMAIL_LOCKED_BOX_PROACTIVE_USER:
               FarmStatsManager.count("emailPermission","allow_email","allowLockBoxRetryProactiveUserPromptsFB");
               break;
            case EmailPopup.EMAIL_LOCKED_BOX_RETRY:
               FarmStatsManager.count("emailPermission","allow_email","allowLockBoxRetryUserPromptsFB");
               break;
            case EmailPopup.EMAIL_LOCKED_BOX:
               FarmStatsManager.count("emailPermission","allow_email","allowLockBoxUserPromptsFB");
               break;
            case EmailPopup.EMAIL_EXISTING_USER:
               FarmStatsManager.count("emailPermission","allow_email","allowExistingUserPromptsFB");
               break;
            case EmailPopup.EMAIL_NEW_USER:
               FarmStatsManager.count("emailPermission","allow_email","allowNewUserPromptsFB");
               break;
            case EmailPopup.EMAIL_WILD_MUSTANG:
               FarmStatsManager.count("emailPermission","allow_email","allowWildMustangPromptsFB");
               break;
            case EmailPopup.EMAIL_REACTIVATION:
               FarmStatsManager.count("emailPermission","allow_email","reactivation");
               break;
            default:
               FarmStatsManager.count("emailPermission","allow_email","allowDefaultPromptsFB");
         }
         (GlobalEngine.socialNetwork as FarmFacebookSocialNetwork).onEmailPermissionDialogClosedWithSource(userAccepted,permissionRequestSource);
      }
      
      private static function prepareForEmailPermissionDialogClosed(permissionRequestSource:Number = 0) : Object
      {
         var result:Object = new Object();
         result["shouldAddPasscodeTransaction"] = false;
         result["shouldAddGrantPermissionTransaction"] = false;
         result["permissionSource"] = permissionRequestSource;
         result["promptMessage"] = ZLocUtils.t("Dialogs","Permissions_email_accept");
         result["shouldAddThankYouPromptMessage"] = true;
         result["statCategory"] = "dontAllowEmail";
         result["hasReceivedGiftForEmailPermissions"] = false;
         if(Global.player.hasReceivedGiftForEmailPermissions)
         {
            result["hasReceivedGiftForEmailPermissions"] = true;
         }
         switch(permissionRequestSource)
         {
            case EmailPopup.EMAIL_REVAMPED_VERBIAGE_USER:
               result["statCategory"] = "allowEmailRevampedUser";
               result["shouldAddGrantPermissionTransaction"] = true;
               result["promptMessage"] = ZLocUtils.t("Dialogs","Permissions_email_accept_revamp");
               break;
            case EmailPopup.EMAIL_PROXY_USER:
               result["statCategory"] = "allowEmailProxyUser";
               result["promptMessage"] = ZLocUtils.t("Dialogs","Permissions_email_accept_revamp_proxy");
               result["shouldAddGrantPermissionTransaction"] = true;
               break;
            case EmailPopup.EMAIL_PROXY_LOCKED_BOX_USER:
               result["promptMessage"] = ZLocUtils.t("Dialogs","Permissions_email_accept_revamp_lockedbox");
               result["statCategory"] = "allowEmailProxyLockedboxUser";
               result["shouldAddPasscodeTransaction"] = true;
               break;
            case EmailPopup.EMAIL_SOCIAL_COMM_USER:
               result["statCategory"] = "allowEmailCommentBoxCheckBox";
               result["shouldAddThankYouPromptMessage"] = false;
               result["shouldAddGrantPermissionTransaction"] = true;
               break;
            case EmailPopup.EMAIL_COMMENT_BOX_VARIANT_SOFTGATE:
               result["statCategory"] = "allowEmailCommentBox_" + MessageManager.COMMENT_BOX_EMAIL_VARIANT_SOFTGATE;
               result["shouldAddThankYouPromptMessage"] = false;
               result["shouldAddGrantPermissionTransaction"] = true;
               break;
            case EmailPopup.EMAIL_PROMO_BAR:
               result["statCategory"] = "allowEmailPromoBar";
               result["shouldAddGrantPermissionTransaction"] = true;
               break;
            case EmailPopup.EMAIL_HUD_ICON:
               result["statCategory"] = "allowEmailHudIcon";
               result["shouldAddGrantPermissionTransaction"] = true;
               break;
            case EmailPopup.EMAIL_MARKET:
               if(result["hasReceivedGiftForEmailPermissions"])
               {
                  result["promptMessage"] = ZLocUtils.t("Dialogs","Permissions_email_accept_no_gift");
               }
               result["shouldAddGrantPermissionTransaction"] = true;
               result["statCategory"] = "allowEmailMarket";
               break;
            case EmailPopup.EMAIL_PROACTIVE_USER:
               result["statCategory"] = "allowEmailProactive";
               if(result["hasReceivedGiftForEmailPermissions"])
               {
                  result["promptMessage"] = ZLocUtils.t("Dialogs","Permissions_email_accept_no_gift");
               }
               result["shouldAddGrantPermissionTransaction"] = true;
               break;
            case EmailPopup.EMAIL_LOCKED_BOX_PROACTIVE_USER:
               result["promptMessage"] = ZLocUtils.t("Dialogs","LockedBoxEmailedPasscode");
               result["statCategory"] = "allowEmailLockBoxProactive";
               result["shouldAddPasscodeTransaction"] = true;
               break;
            case EmailPopup.EMAIL_LOCKED_BOX_RETRY:
               result["promptMessage"] = ZLocUtils.t("Dialogs","LockedBoxEmailConfirm");
               result["statCategory"] = "allowEmailLockBoxOnRetry";
               result["shouldAddPasscodeTransaction"] = true;
               break;
            case EmailPopup.EMAIL_LOCKED_BOX:
               result["promptMessage"] = ZLocUtils.t("Dialogs","LockedBoxEmailConfirm");
               result["statCategory"] = "allowEmailLockBox";
               result["shouldAddPasscodeTransaction"] = true;
               break;
            case EmailPopup.EMAIL_EXISTING_USER:
               result["statCategory"] = "allowEmailExistingUser";
               result["shouldAddGrantPermissionTransaction"] = true;
               break;
            case EmailPopup.EMAIL_NEW_USER:
               result["statCategory"] = "allowEmailNewUser";
               result["shouldAddGrantPermissionTransaction"] = true;
               break;
            case EmailPopup.EMAIL_NEW_USER_START_TUTORIAL_COIN:
               result["statCategory"] = "allowEmailNewUserStartTutorialCoin";
               result["promptMessage"] = ZLocUtils.t("Dialogs","Permissions_email_accept_start_tutorial_coin");
               result["shouldAddGrantPermissionTransaction"] = true;
               break;
            case EmailPopup.EMAIL_NEW_USER_START_TUTORIAL_COW:
               result["statCategory"] = "allowEmailNewUserStartTutorialCow";
               result["promptMessage"] = ZLocUtils.t("Dialogs","Permissions_email_accept_start_tutorial_cow");
               result["shouldAddGrantPermissionTransaction"] = true;
               break;
            case EmailPopup.EMAIL_WILD_MUSTANG:
               result["statCategory"] = "allowWildMustang";
               result["promptMessage"] = ZLocUtils.t("Dialogs","Permissions_email_accept_wild_mustang");
               result["shouldAddGrantPermissionTransaction"] = true;
               break;
            case EmailPopup.EMAIL_REACTIVATION:
               result["statCategory"] = "reactivation";
               result["shouldAddThankYouPromptMessage"] = false;
               result["shouldAddGrantPermissionTransaction"] = true;
               result["permissionSource"] = null;
         }
         return result;
      }
      
      public static function onEmailPermissionDialogClosed(userAccepted:Boolean, permissionRequestSource:Number = 0) : void
      {
         var parameters:Object = prepareForEmailPermissionDialogClosed(permissionRequestSource);
         if(userAccepted)
         {
            if(parameters["shouldAddPasscodeTransaction"])
            {
               TransactionManager.addTransaction(new TSendEmailPasscode("lockedbox"),true);
            }
            else if(parameters["shouldAddGrantPermissionTransaction"])
            {
               TransactionManager.addTransaction(new TGrantEmailPermission(parameters["permissionSource"]),true);
            }
            if(parameters["shouldAddThankYouPromptMessage"])
            {
               UI.displayMessage(parameters["promptMessage"]);
            }
            FarmStatsManager.count("emailPermission",parameters["statCategory"]);
         }
      }
      
      public static function parseEmailBits(result:Object) : void
      {
         var hasEmailPermission:Boolean = false;
         var currentDay:Number = NaN;
         var daysBetweenEmailRequests:int = 0;
         var dayMod:int = 0;
         var idMod:int = 0;
         var daysBetweenRevampEmailRequests:int = 0;
         var dayRevampMod:int = 0;
         var idRevampMod:int = 0;
         if(Global.farmSocialNetwork.emailSupported() && Boolean(result.player))
         {
            if(result.player.seenRevampEmail)
            {
               Global.player.seenRevampEmail = result.player.seenRevampEmail;
            }
            if(result.player.timeLastSeenRevampEmail)
            {
               Global.player.timeLastSeenRevampEmail = result.player.timeLastSeenRevampEmail;
            }
            if(result.player.seenRevampEmailProxy)
            {
               Global.player.seenRevampProxyEmail = result.player.seenRevampEmailProxy;
            }
            if(result.player.timeLastSeenRevampEmailProxy)
            {
               Global.player.timeLastSeenRevampProxyEmail = result.player.timeLastSeenRevampEmailProxy;
            }
            if(result.player.seenRevampEmailLockedbox)
            {
               Global.player.seenRevampLockedboxEmail = result.player.seenRevampEmailLockedbox;
            }
            if(result.player.timeLastSeenRevampEmailLockedbox)
            {
               Global.player.timeLastSeenRevampLockedboxEmail = result.player.timeLastSeenRevampEmailLockedbox;
            }
            if(result.player.seenRequestEmail)
            {
               Global.player.seenRequestEmail = result.player.seenRequestEmail;
            }
            if(result.player.hourLastSeenRequestEmail)
            {
               Global.player.hourLastSeenRequestEmail = result.player.hourLastSeenRequestEmail;
            }
            if(Boolean(result.player.hasReceivedGiftForEmailPermissions) && 0 < result.player.hasReceivedGiftForEmailPermissions)
            {
               Global.player.hasReceivedGiftForEmailPermissions = true;
            }
            hasEmailPermission = GlobalEngine.socialNetwork.userHasEmailPermission();
            currentDay = GlobalEngine.getTimer() / 1000 / 60 / 60 / 24;
            daysBetweenEmailRequests = Global.farmGameSettingsManager.getInt("daysBetweenEmailRequests",5);
            dayMod = currentDay % daysBetweenEmailRequests;
            idMod = int(GlobalEngine.socialNetwork.getLoggedInUserId()) % daysBetweenEmailRequests;
            daysBetweenRevampEmailRequests = Global.farmGameSettingsManager.getInt("daysBetweenRevampEmailRequests",2);
            dayRevampMod = currentDay % daysBetweenRevampEmailRequests;
            idRevampMod = int(GlobalEngine.socialNetwork.getLoggedInUserId()) % daysBetweenRevampEmailRequests;
            if(dayRevampMod == idRevampMod)
            {
               if(!hasEmailPermission)
               {
                  EmailManager.displayEmailPermissionPrompt(EmailPopup.EMAIL_REVAMPED_VERBIAGE_USER);
                  FarmStatsManager.count("emailPermission","revamp_welcome");
               }
               else if(result.player.emailType == 0)
               {
                  if(!Global.player.getSeenFlag("placedLockedBox"))
                  {
                     EmailManager.displayEmailPermissionPrompt(EmailPopup.EMAIL_PROXY_USER);
                     FarmStatsManager.count("emailPermission","revamp_proxy");
                  }
                  else
                  {
                     EmailManager.displayEmailPermissionPrompt(EmailPopup.EMAIL_PROXY_LOCKED_BOX_USER);
                     FarmStatsManager.count("emailPermission","revamp_lockedbox");
                  }
               }
            }
            else if(dayMod == idMod)
            {
               if(!hasEmailPermission)
               {
                  EmailManager.displayEmailPermissionPrompt(EmailPopup.EMAIL_EXISTING_USER);
                  FarmStatsManager.count("emailPermission","daily_chance");
               }
            }
            else if(!result.player.hasReceivedGiftForEmailPermissions || 0 == result.player.hasReceivedGiftForEmailPermissions)
            {
               if(hasEmailPermission)
               {
                  (GlobalEngine.socialNetwork as FarmFacebookSocialNetwork).onEmailPermissionDialogClosedWithSource(true,EmailPopup.EMAIL_PROACTIVE_USER);
                  FarmStatsManager.count("emailPermission","allow_email","allowProactiveUserFB");
               }
               else
               {
                  Global.hud.iconQueue.addIcon("EmailPermission");
               }
            }
         }
      }
   }
}

class SingletonEnforcer
{
   
   public function SingletonEnforcer()
   {
      super();
   }
}

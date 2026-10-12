package Display.Promo
{
   import Classes.util.ZLocUtils;
   import Display.FarmDynamicDialog;
   import Managers.EnglishSweepstakesPromoManager;
   import Managers.FarmStatsManager;
   import com.troyer.widget.controller.ResizeController;
   import com.troyer.widget.event.WidgetControllerEvent;
   import com.troyer.widget.view.BaseWidgetView;
   import com.troyer.widget.view.TextFieldView;
   import flash.events.Event;
   
   public class EnglishSweepstakesDialog extends FarmDynamicDialog
   {
      
      public static const ECSWEEPS_POPUP_A:String = "ECSweeps_PopupA";
      
      public static const ECSWEEPS_POPUP_B:String = "ECSweeps_PopupB";
      
      public static const ECSWEEPS_POPUP_C:String = "ECSweeps_PopupC";
      
      public static const ECSWEEPS_POPUP_D:String = "ECSweeps_PopupD";
      
      public static const TOS_URL:String = "http://www.zynga.com/about/terms-of-service.php";
      
      public static const RULES_URL:String = "http://www.facebook.com/pages/FarmVille-English-Countryside/128597000543889?sk=app_6009294086";
      
      private var m_dialog:FarmDynamicDialog;
      
      private var m_configType:String;
      
      public function EnglishSweepstakesDialog(view:BaseWidgetView)
      {
         super(view);
      }
      
      override public function setup() : void
      {
         var numEntries:Number = NaN;
         var resizeController:ResizeController = null;
         var base:BaseWidgetView = null;
         if(this.m_configType)
         {
            switch(this.m_configType)
            {
               case ECSWEEPS_POPUP_A:
                  this.m_dialog = FarmDynamicDialog.createDialog("ECSweeps_PopupA",FarmDynamicDialog);
                  this.setShortcutAttribute("line1",TextFieldView.ATTRIBUTE_TEXT,ZLocUtils.t("Dialogs","EnglishSweepstakes_PrizesInFarmVille"));
                  this.setShortcutAttribute("line2",TextFieldView.ATTRIBUTE_TEXT,ZLocUtils.t("Dialogs","EnglishSweepstakes_GoFarming",{"levelNum":EnglishSweepstakesPromoManager.getManager().getNumberConstant("requiredLevel")}));
                  this.setShortcutAttribute("line3",TextFieldView.ATTRIBUTE_TEXT,ZLocUtils.t("Dialogs","EnglishSweepstakes_GrandPrize"));
                  this.setShortcutAttribute("line4",TextFieldView.ATTRIBUTE_TEXT,ZLocUtils.t("Dialogs","EnglishSweepstakes_RulesShort",{"RULES_URL":RULES_URL}));
                  this.setShortcutAttribute("playButton",TextFieldView.ATTRIBUTE_TEXT,ZLocUtils.t("Dialogs","EnglishSweepstakes_PlayFarmVille"));
                  this.setShortcutListener("playButton",WidgetControllerEvent.BUTTON_PRESSED,this.onPlayPressed);
                  break;
               case ECSWEEPS_POPUP_B:
                  this.m_dialog = FarmDynamicDialog.createDialog("ECSweeps_PopupB",FarmDynamicDialog);
                  this.setShortcutAttribute("line1",TextFieldView.ATTRIBUTE_TEXT,ZLocUtils.t("Dialogs","EnglishSweepstakes_PrizesInFarmVille"));
                  this.setShortcutAttribute("line2",TextFieldView.ATTRIBUTE_TEXT,ZLocUtils.t("Dialogs","EnglishSweepstakes_FirstQuest"));
                  this.setShortcutAttribute("line3",TextFieldView.ATTRIBUTE_TEXT,ZLocUtils.t("Dialogs","EnglishSweepstakes_GrandPrize"));
                  this.setShortcutAttribute("line4",TextFieldView.ATTRIBUTE_TEXT,ZLocUtils.t("Dialogs","EnglishSweepstakes_RulesShort",{"RULES_URL":RULES_URL}));
                  this.setShortcutAttribute("playButton",TextFieldView.ATTRIBUTE_TEXT,ZLocUtils.t("Dialogs","EnglishSweepstakes_PlayFarmVille"));
                  this.setShortcutListener("playButton",WidgetControllerEvent.BUTTON_PRESSED,this.onPlayPressed);
                  break;
               case ECSWEEPS_POPUP_C:
                  this.m_dialog = FarmDynamicDialog.createDialog("ECSweeps_PopupC",FarmDynamicDialog);
                  numEntries = EnglishSweepstakesPromoManager.getRewardEntryCount();
                  if(numEntries == 1)
                  {
                     this.setShortcutAttribute("line1",TextFieldView.ATTRIBUTE_TEXT,ZLocUtils.t("Dialogs","EnglishSweepstakes_JustCongratulations") + "\n" + ZLocUtils.t("Dialogs","EnglishSweepstakes_EntriesSingle",{
                        "quantity":numEntries,
                        "entryword":ZLocUtils.tk("Dialogs","EnglishSweepstakes_Entry_word","",numEntries)
                     }));
                  }
                  else
                  {
                     this.setShortcutAttribute("line1",TextFieldView.ATTRIBUTE_TEXT,ZLocUtils.t("Dialogs","EnglishSweepstakes_JustCongratulations") + "\n" + ZLocUtils.t("Dialogs","EnglishSweepstakes_EntriesMultiple",{
                        "quantity":numEntries,
                        "entryword":ZLocUtils.tk("Dialogs","EnglishSweepstakes_Entry_word","",numEntries)
                     }));
                  }
                  this.setShortcutAttribute("line2",TextFieldView.ATTRIBUTE_TEXT,ZLocUtils.t("Dialogs","EnglishSweepstakes_EarnMore"));
                  this.setShortcutAttribute("line3",TextFieldView.ATTRIBUTE_TEXT,ZLocUtils.t("Dialogs","EnglishSweepstakes_KeepEyeOut"));
                  this.setShortcutAttribute("line4",TextFieldView.ATTRIBUTE_TEXT,ZLocUtils.t("Dialogs","EnglishSweepstakes_RulesShort",{"RULES_URL":RULES_URL}));
                  this.setShortcutAttribute("playButton",TextFieldView.ATTRIBUTE_TEXT,ZLocUtils.t("Dialogs","EnglishSweepstakes_PlayFarmVille"));
                  this.setShortcutListener("playButton",WidgetControllerEvent.BUTTON_PRESSED,this.onPlayPressed);
                  if(!EnglishSweepstakesPromoManager.userCanPostFeed())
                  {
                     this.setShortcutAttribute("shareButton",BaseWidgetView.ATTRIBUTE_OBSTRUCT,false);
                     this.setShortcutAttribute("shareButton",BaseWidgetView.ATTRIBUTE_VISIBLE,false);
                  }
                  else
                  {
                     this.setShortcutAttribute("shareButton",TextFieldView.ATTRIBUTE_TEXT,ZLocUtils.t("Dialogs","JustShare"));
                     this.setShortcutListener("shareButton",WidgetControllerEvent.BUTTON_PRESSED,this.onSharePressed);
                  }
                  break;
               case ECSWEEPS_POPUP_D:
                  this.m_dialog = FarmDynamicDialog.createDialog("ECSweeps_PopupD",FarmDynamicDialog);
                  this.setShortcutAttribute("line1",TextFieldView.ATTRIBUTE_TEXT,ZLocUtils.t("Dialogs","EnglishSweepstakes_JustCongratulations") + "\n" + ZLocUtils.t("Dialogs","EnglishSweepstakes_EligibleEnter"));
                  this.setShortcutAttribute("line2",TextFieldView.ATTRIBUTE_TEXT,ZLocUtils.t("Dialogs","EnglishSweepstakes_ClickOkay"));
                  this.setShortcutAttribute("line3",TextFieldView.ATTRIBUTE_TEXT,ZLocUtils.t("Dialogs","EnglishSweepstakes_RulesLong1",{
                     "TOS_URL":TOS_URL,
                     "RULES_URL":RULES_URL
                  }) + "\n" + ZLocUtils.t("Dialogs","EnglishSweepstakes_RulesLong2"));
                  this.setShortcutAttribute("okayButton",TextFieldView.ATTRIBUTE_TEXT,ZLocUtils.t("Dialogs","Okay"));
                  this.setShortcutListener("okayButton",WidgetControllerEvent.BUTTON_PRESSED,this.onOkayPressed);
                  resizeController = this.getShortcutController("mask") as ResizeController;
                  if(resizeController)
                  {
                     base = resizeController.getAttribute(ResizeController.ATTRIBUTE_VIEW_TO_PIN);
                     base.getController().addViewListener(WidgetControllerEvent.CLOSE,this.onNoThanksPressed);
                  }
            }
         }
      }
      
      public function setConfigType(configType:String) : void
      {
         this.m_configType = configType;
      }
      
      private function onPlayPressed(event:WidgetControllerEvent) : void
      {
         destroy();
      }
      
      private function onSharePressed(event:WidgetControllerEvent) : void
      {
         EnglishSweepstakesPromoManager.onBeginShareFeedFlow();
         FarmStatsManager.count("feed","englandsweeps","banner");
         destroy();
      }
      
      private function onOkayPressed(event:WidgetControllerEvent) : void
      {
         EnglishSweepstakesPromoManager.claimFirstSweepstakesEntry();
         FarmStatsManager.count("englandsweeps","enterpop","enters");
         destroy();
      }
      
      private function onNoThanksPressed(event:Event) : void
      {
         FarmStatsManager.count("englandsweeps","enterpop","nothanks");
         destroy();
      }
   }
}


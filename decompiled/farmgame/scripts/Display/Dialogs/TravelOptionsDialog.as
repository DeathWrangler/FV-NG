package Display.Dialogs
{
   import Classes.util.ZLocUtils;
   import Display.FarmDynamicDialog;
   import Engine.Managers.TransactionManager;
   import Transactions.TSaveOptions;
   import com.troyer.widget.controller.CheckBoxController;
   import com.troyer.widget.controller.ImageController;
   import com.troyer.widget.event.WidgetControllerEvent;
   import com.troyer.widget.view.BaseWidgetView;
   import com.troyer.widget.view.TextFieldView;
   
   public class TravelOptionsDialog extends FarmDynamicDialog
   {
      
      public static const IMPORT_DESTINATION_WORLD_TYPE:String = "destinationWorld";
      
      public static const IMPORT_TRAVEL_CALLBACK:String = "travelCallback";
      
      private static const IMAGE_URL_MODE_PLAY:String = "assets/dialogs/FV_Support/FV_Expansions_Features/Contingency/FV_xuk_contingencyPlay.png";
      
      private static const IMAGE_URL_MODE_PAUSE:String = "assets/dialogs/FV_Support/FV_Expansions_Features/Contingency/FV_xuk_contingencyPause.png";
      
      private var m_destinationWorldType:String;
      
      private var m_destinationWorldFriendlyName:String;
      
      private var m_currentWorldFriendlyName:String;
      
      private var m_travelCallback:Function;
      
      private var m_shouldFreezeFarm:Boolean;
      
      private var m_pauseToggle:CheckBoxController;
      
      public function TravelOptionsDialog(view:BaseWidgetView)
      {
         super(view);
         if(Global.player.options.hasOwnProperty("shouldFreezeFarm"))
         {
            this.m_shouldFreezeFarm = Global.player.options.shouldFreezeFarm > 0;
         }
         else
         {
            this.m_shouldFreezeFarm = false;
         }
      }
      
      override public function setup() : void
      {
         this.m_travelCallback = this.getImport(IMPORT_TRAVEL_CALLBACK);
         this.m_destinationWorldType = this.getImport(IMPORT_DESTINATION_WORLD_TYPE);
         this.m_destinationWorldFriendlyName = Global.worldManager.getWorldFriendlyName(this.m_destinationWorldType);
         this.m_currentWorldFriendlyName = Global.worldManager.getWorldFriendlyName();
         this.setShortcutAttribute("titletext",TextFieldView.ATTRIBUTE_TEXT,ZLocUtils.t("Dialogs","TravelFreezeSelect_Title",{"world":this.m_destinationWorldFriendlyName}));
         this.setShortcutAttribute("cancelButton",TextFieldView.ATTRIBUTE_TEXT,ZLocUtils.t("Dialogs","Cancel"));
         this.setShortcutAttribute("okayButton",TextFieldView.ATTRIBUTE_TEXT,ZLocUtils.t("Dialogs","TravelFreezeSelect_AcceptButton"));
         this.getShortcutController("okayButton").listen(WidgetControllerEvent.BUTTON_PRESSED,this.onTravelButtonPress);
         this.setShortcutAttribute("changeOptionsText",TextFieldView.ATTRIBUTE_TEXT,ZLocUtils.t("Dialogs","TravelFreezeSelect_ChooseOptions",{"world":this.m_currentWorldFriendlyName}));
         this.m_pauseToggle = this.getShortcutController("pauseToggle") as CheckBoxController;
         this.m_pauseToggle.setAttribute(CheckBoxController.ATTRIBUTE_CHECKED,this.m_shouldFreezeFarm);
         this.m_pauseToggle.listen(WidgetControllerEvent.BUTTON_PRESSED,this.onPauseToggle);
         this.setupTravelText();
         this.setupFlagIcons();
         this.setupModeIcon();
      }
      
      private function setupTravelText() : void
      {
         var bodyText:String = " ";
         if(this.m_shouldFreezeFarm)
         {
            bodyText += ZLocUtils.t("Dialogs","TravelFreezeSelect_Body_freeze");
         }
         else
         {
            bodyText += ZLocUtils.t("Dialogs","TravelFreezeSelect_Body_nofreeze");
         }
         this.setShortcutAttribute("bodyText",TextFieldView.ATTRIBUTE_TEXT,bodyText);
      }
      
      private function setupFlagIcons() : void
      {
         var currentWorldFlagUrl:String = null;
         var destinationWorldFlagUrl:String = null;
         var currentWorldConfig:Object = Global.worldSettingsManager.getConfigByWorld(Global.worldManager.currentWorldType);
         if(currentWorldConfig.hasOwnProperty("travelOptionsDialog"))
         {
            currentWorldFlagUrl = currentWorldConfig.travelOptionsDialog.largeIcon.toString();
         }
         if(currentWorldFlagUrl)
         {
            this.setShortcutAttribute("leftFlag",ImageController.ATTRIBUTE_SOURCE,Global.getAssetURL(currentWorldFlagUrl));
         }
         var destinationWorldConfig:Object = Global.worldSettingsManager.getConfigByWorld(this.m_destinationWorldType);
         if(destinationWorldConfig.hasOwnProperty("travelOptionsDialog"))
         {
            destinationWorldFlagUrl = destinationWorldConfig.travelOptionsDialog.smallIcon.toString();
         }
         if(destinationWorldFlagUrl)
         {
            this.setShortcutAttribute("rightFlag",ImageController.ATTRIBUTE_SOURCE,Global.getAssetURL(destinationWorldFlagUrl));
         }
      }
      
      private function setupModeIcon() : void
      {
         if(this.m_shouldFreezeFarm)
         {
            this.setShortcutAttribute("playPause",ImageController.ATTRIBUTE_SOURCE,IMAGE_URL_MODE_PAUSE);
         }
         else
         {
            this.setShortcutAttribute("playPause",ImageController.ATTRIBUTE_SOURCE,IMAGE_URL_MODE_PLAY);
         }
      }
      
      private function onTravelButtonPress(event:WidgetControllerEvent) : void
      {
         this.updateDialog(true);
         this.destroy();
         if(this.m_travelCallback != null)
         {
            this.m_travelCallback(this.m_destinationWorldType,this.m_shouldFreezeFarm);
         }
      }
      
      private function onPauseToggle(event:WidgetControllerEvent) : void
      {
         this.updateDialog(false);
      }
      
      private function updateDialog(sendSave:Boolean) : void
      {
         this.m_shouldFreezeFarm = this.m_pauseToggle.getAttribute(CheckBoxController.ATTRIBUTE_CHECKED);
         this.setupTravelText();
         this.setupModeIcon();
         var options:Object = Global.player.options;
         if(sendSave && options.shouldFreezeFarm != this.m_shouldFreezeFarm)
         {
            options.shouldFreezeFarm = this.m_shouldFreezeFarm;
            TransactionManager.addTransaction(new TSaveOptions(options));
         }
      }
   }
}


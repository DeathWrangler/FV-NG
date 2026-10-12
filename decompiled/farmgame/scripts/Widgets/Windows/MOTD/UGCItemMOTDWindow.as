package Widgets.Windows.MOTD
{
   import Classes.UGC.UGCItemDefinition;
   import Classes.ZItem.FarmItem;
   import Classes.ZItem.IUGCItem;
   import Classes.util.ObjectUtil;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Engine.Managers.ErrorManager;
   import Managers.FarmStatsManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Windows.FarmWindow;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.utils.getDefinitionByName;
   
   public class UGCItemMOTDWindow extends CustomWindowMOTDBase
   {
      
      private var m_displayParams:Object = null;
      
      private var m_ugcItemName:String = "";
      
      public function UGCItemMOTDWindow(displayParams:Object = null)
      {
         var assetURL:String = null;
         this.m_displayParams = displayParams;
         if(this.m_displayParams != null)
         {
            if(this.m_displayParams.hasOwnProperty("dialog"))
            {
               assetURL = this.m_displayParams["dialog"];
               super(assetURL);
            }
            else
            {
               ErrorManager.addError("UGCItem MOTD - no swf passed");
            }
            if(this.m_displayParams.hasOwnProperty("ugcItemName"))
            {
               this.m_ugcItemName = this.m_displayParams["ugcItemName"];
            }
            else
            {
               ErrorManager.addError("UGCItem MOTD - no ugcItem passed");
            }
         }
         else
         {
            ErrorManager.addError("UGCItem MOTD - no windowParams in motd.xml");
         }
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         if(ObjectUtil.pathExists(m_window,"mainWindow"))
         {
            addWidget(new ZwFrame(m_window.mainWindow));
            if(ObjectUtil.pathExists(m_window,"mainWindow","title_tf"))
            {
               addWidget(new ZwTextField(m_window.mainWindow.title_tf,ZLocUtils.t("Dialogs","MOTD_UGCItemTitleText")));
            }
            if(ObjectUtil.pathExists(m_window,"mainWindow","body_tf"))
            {
               addWidget(new ZwTextField(m_window.mainWindow.body_tf,ZLocUtils.t("Dialogs","MOTD_UGCItemBodyText")));
            }
            if(ObjectUtil.pathExists(m_window,"mainWindow","accept_bt"))
            {
               addWidget(new FarmAnimatedTextButton(m_window.mainWindow.accept_bt,ZLocUtils.t("Dialogs","MOTD_UGCItemButtonText"),this.onUGCItemEditorTrigger));
            }
         }
         FarmStatsManager.count("ugc","MOTD","view_" + this.m_ugcItemName);
      }
      
      override protected function onShow() : void
      {
         super.onShow();
         if(ObjectUtil.pathExists(m_window,"mainWindow","horse_mc"))
         {
            (m_window.mainWindow.horse_mc as MovieClip).play();
         }
      }
      
      private function onUGCItemEditorTrigger(event:MouseEvent) : void
      {
         var ugcItem:FarmItem = null;
         var ugcItemDefinition:UGCItemDefinition = null;
         var windowClass:Class = null;
         var window:FarmWindow = null;
         if(this.m_ugcItemName != null)
         {
            ugcItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_ugcItemName);
            if(ugcItem != null)
            {
               ugcItemDefinition = Global.farmGameSettingsManager.getUGCItemDefinition(ugcItem.name);
               windowClass = getDefinitionByName(ugcItemDefinition.editorConfig.windowClass) as Class;
               window = new windowClass(ugcItem as IUGCItem);
               UI.displayPopup(window,false);
               FarmStatsManager.count("ugc","MOTD","click_create_" + this.m_ugcItemName);
            }
            else
            {
               ErrorManager.addError("Invalid ugcItemName specified for MOTD");
            }
         }
         else
         {
            ErrorManager.addError("No ugcItemName windowParam for MOTD");
         }
         super.onClose(event);
      }
      
      override protected function onClose(event:Event) : void
      {
         FarmStatsManager.count("ugc","MOTD","x_cancel_" + this.m_ugcItemName);
         super.onClose(event);
      }
   }
}


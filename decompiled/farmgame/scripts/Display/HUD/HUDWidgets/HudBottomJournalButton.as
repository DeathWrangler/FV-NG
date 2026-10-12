package Display.HUD.HUDWidgets
{
   import Classes.Quest.PrerequisiteUtility;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Managers.FarmStatsManager;
   import Managers.JournalManager;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.filters.DropShadowFilter;
   
   public class HudBottomJournalButton extends HUDWidget
   {
      
      private static const HUD_MC:String = "hud_mc";
      
      private static const NOTIF_MC:String = "notifUpdate_mc";
      
      private static const X_OFFSET:int = 100;
      
      private static const Y_OFFSET:int = 80;
      
      private var m_featureName:String;
      
      private var m_hudButton:FarmAnimatedButton;
      
      private var m_notification:MovieClip;
      
      private var m_manager:JournalManager;
      
      private var m_isVisible:Boolean = false;
      
      public function HudBottomJournalButton(assetPath:String)
      {
         super(assetPath,Global.hud);
         this.m_manager = JournalManager.getInstance();
      }
      
      public function get isVisible() : Boolean
      {
         return this.m_isVisible;
      }
      
      public function showButton() : void
      {
         Global.hud.setBottomHudJournalButton(this as HudBottomJournalButton);
         this.m_isVisible = true;
      }
      
      override protected function onLoadComplete(event:Event) : void
      {
         var description:String = null;
         super.onLoadComplete(event);
         this.setXY();
         var parentFrame:ZwFrame = new ZwFrame(m_element);
         (parentFrame.element as MovieClip).stop();
         m_element.filters = [new DropShadowFilter()];
         if(m_element.hasOwnProperty(HUD_MC))
         {
            addWidget(this.m_hudButton = new FarmAnimatedButton(m_element[HUD_MC],this.triggerJournal),true);
            description = ZLocUtils.t("Dialogs",this.m_featureName + "_hudOnHover");
            this.m_hudButton.attachTooltip(new FarmTextTooltip(description));
            if(m_element[HUD_MC].hasOwnProperty(NOTIF_MC))
            {
               this.m_notification = m_element[HUD_MC][NOTIF_MC] as MovieClip;
            }
            if(this.m_manager.isJournalNotificationAvailable())
            {
               this.displayJournalNotification = true;
            }
            else
            {
               this.displayJournalNotification = false;
            }
         }
      }
      
      public function set displayJournalNotification(value:Boolean) : void
      {
         if(this.m_notification)
         {
            this.m_notification.visible = value;
         }
      }
      
      private function triggerJournal(event:Event) : void
      {
         FarmStatsManager.count(this.m_manager.featureName(),"FOTW_HUD_ICON","click");
         if(PrerequisiteUtility.arePrerequisitesMet(this.m_manager.prereqs))
         {
            this.m_manager.setJournalNotificationSeen();
            JournalManager.getInstance().showUI();
         }
      }
      
      public function setXY() : void
      {
         if(m_loader)
         {
            m_loader.x = (GlobalEngine.stage.stageWidth - UI.DEFAULT_WIDTH) / 2 - X_OFFSET;
            m_loader.y = Global.stage.stageHeight - Y_OFFSET;
         }
      }
   }
}


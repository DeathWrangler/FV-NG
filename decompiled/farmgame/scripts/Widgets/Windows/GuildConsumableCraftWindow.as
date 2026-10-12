package Widgets.Windows
{
   import Classes.Constants.ZLocConstants;
   import Classes.util.ZLocUtils;
   import Managers.GuildManager;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.GuildConsumableCraftSlotContainerFrame;
   
   public class GuildConsumableCraftWindow extends FarmWindow
   {
      
      private static const WINDOW_PREFIX:String = "guild_craft_";
      
      private var m_featureName:String;
      
      public var m_owner:GuildMainWindow;
      
      private var m_consumableCraftSlotFrame:GuildConsumableCraftSlotContainerFrame;
      
      public const GUILD_CONSUMABLE_CRAFT_FLAG:String = "guild_consumable_craft_flag";
      
      public function GuildConsumableCraftWindow(featureName:String = null, assetPath:String = "")
      {
         this.m_featureName = featureName;
         super(assetPath);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         if(m_window.hasOwnProperty("title_tf"))
         {
            addWidget(new ZwTextField(m_window["title_tf"],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,WINDOW_PREFIX + "title")));
         }
         if(m_window.hasOwnProperty("body_tf"))
         {
            addWidget(new ZwTextField(m_window["body_tf"],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,WINDOW_PREFIX + "subtitle")));
         }
         this.m_consumableCraftSlotFrame = new GuildConsumableCraftSlotContainerFrame(m_window,this.m_featureName,this) as GuildConsumableCraftSlotContainerFrame;
         this.m_consumableCraftSlotFrame.visible = true;
         addWidget(this.m_consumableCraftSlotFrame,true);
      }
      
      private function get manager() : GuildManager
      {
         return GuildManager.getInstance();
      }
      
      override public function close() : void
      {
         if(this.manager.m_guildMainWindow)
         {
            this.manager.m_guildMainWindow.m_overlayMC.visible = false;
            if(GuildMainWindow.m_FTUEState == 6)
            {
               ++GuildMainWindow.m_FTUEState;
               this.manager.m_guildMainWindow.resumeFTUEFlow();
            }
         }
         if(this.manager.m_welcomeWindow)
         {
            this.manager.m_welcomeWindow.m_overlayMC.visible = false;
         }
         super.close();
      }
      
      public function refreshGuildCraftWindow() : void
      {
         if(this.m_consumableCraftSlotFrame)
         {
            this.m_consumableCraftSlotFrame.refresh();
         }
      }
   }
}


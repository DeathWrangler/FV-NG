package Widgets.Windows.FeatureCrafting
{
   import Classes.FeatureCrafting.FeatureCraftingSystem;
   import Classes.util.FacebookSocialNetwork;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Managers.FeatureCraftingManager;
   import Transactions.TGenericTransaction;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.FeatureCrafting.FeatureCraftingLevelUpSlotContainerFrame;
   import Widgets.Windows.FarmWindow;
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class FeatureCraftingLevelUpWindow extends FarmWindow
   {
      
      private var m_system:FeatureCraftingSystem;
      
      private var m_coins:int;
      
      private var m_xp:int;
      
      private var m_unlocks:Array;
      
      public function FeatureCraftingLevelUpWindow(system:FeatureCraftingSystem, coins:int, xp:int, unlocks:Array = null)
      {
         this.m_system = system;
         this.m_coins = coins;
         this.m_xp = xp;
         this.m_unlocks = unlocks;
         var assetName:String = !unlocks || unlocks.length == 0 ? FeatureCraftingSystem.ASSET_DIALOG_LEVEL_UP : FeatureCraftingSystem.ASSET_DIALOG_LEVEL_UP_UNLOCK;
         super(this.m_system.getAssetUrl(assetName));
      }
      
      public static function display(system:FeatureCraftingSystem, coins:int, xp:int, unlocks:Array = null) : FeatureCraftingLevelUpWindow
      {
         var window:FeatureCraftingLevelUpWindow = null;
         if(system)
         {
            window = new FeatureCraftingLevelUpWindow(system,coins,xp,unlocks);
            UI.displayPopup(window,false,"FeatureCraftingLevelUpWindow",true);
         }
         return window;
      }
      
      override protected function postLoadComplete() : void
      {
         var slotContainerElement:DisplayObject = null;
         var slots:FeatureCraftingLevelUpSlotContainerFrame = null;
         addWidget(new ZwTextField(m_window.title_tf,this.m_system.getLocalizedString("LevelUpWindow_Title"))) as ZwTextField;
         addWidget(new ZwTextField(m_window.copy_tf,this.m_system.getLocalizedString("LevelUpWindow_Message",{
            "systemName":this.m_system.friendlyTitle,
            "level":this.m_system.getPointLevel()
         }))) as ZwTextField;
         if(Boolean(this.m_unlocks) && this.m_unlocks.length > 0)
         {
            addWidget(new ZwTextField(m_window.unlocked_tf,this.m_system.getLocalizedString("LevelUpWindow_Unlocks"))) as ZwTextField;
            if(this.m_unlocks.length == 1)
            {
               slotContainerElement = m_window.slots1_mc;
            }
            else if(this.m_unlocks.length == 2)
            {
               slotContainerElement = m_window.slots2_mc;
            }
            else
            {
               slotContainerElement = m_window.slots3_mc;
            }
            slots = addWidget(new FeatureCraftingLevelUpSlotContainerFrame(slotContainerElement)) as FeatureCraftingLevelUpSlotContainerFrame;
            slots.items = this.m_unlocks;
         }
         addWidget(new ZwTextField(m_window.coins_tf,String(this.m_coins))) as ZwTextField;
         addWidget(new ZwTextField(m_window.xp_tf,String(this.m_xp))) as ZwTextField;
         addWidget(new FarmAnimatedTextButton(m_window.accept_bt,ZLocUtils.t("Dialogs","Share"),this.onShareButtonClick));
      }
      
      override protected function release() : void
      {
         this.m_unlocks = null;
         super.release();
      }
      
      override protected function onClose(event:Event) : void
      {
         if(m_closeButton.enabled)
         {
            super.onClose(event);
         }
      }
      
      public function get system() : FeatureCraftingSystem
      {
         return this.m_system;
      }
      
      public function onShareButtonClick(event:MouseEvent) : void
      {
         var params:Array = [this.m_system.name,this.m_system.getPointLevel()];
         TransactionManager.addTransaction(new TGenericTransaction(FeatureCraftingManager.SERVICE_NAME,"postLevelUpFeed",this.onPostFeedCallback,params),true);
         close();
      }
      
      private function onPostFeedCallback(result:Object) : void
      {
         if(Boolean(result) && Boolean(result["feedData"]))
         {
            (GlobalEngine.socialNetwork as FacebookSocialNetwork).publishResultsFromTransaction(result["feedData"]);
         }
      }
   }
}


package Widgets.Windows.BuriedTreasure
{
   import Classes.BuriedTreasure;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.Dialogs.GenericDialog;
   import Display.UI;
   import Managers.BuriedTreasureManager;
   import Managers.FarmStatsManager;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.ObjectPreviewFrame;
   import Widgets.Windows.FarmWindow;
   import flash.events.Event;
   import flash.geom.Point;
   
   public class BuriedTreasureWindow extends FarmWindow
   {
      
      private static const ASSET_PATH:String = "assets/dialogs/FV_buriedTreasure.swf";
      
      private static const PREVIEW_WIDTH:int = 100;
      
      private var m_treasure:BuriedTreasure;
      
      private var m_dialog:GenericDialog;
      
      public function BuriedTreasureWindow(treasure:BuriedTreasure)
      {
         super(ASSET_PATH);
         this.m_treasure = treasure;
      }
      
      override protected function onLoadComplete(event:Event) : void
      {
         var treasureItem:FarmItem = null;
         var treasureFrame:ZwFrame = null;
         super.onLoadComplete(event);
         addWidget(new ZwTextField(m_window.generic_tf,ZLocUtils.t("Dialogs","BuriedTreasureUnlockDescription"))) as ZwTextField;
         if(m_window.hasOwnProperty("generic2_tf"))
         {
            addWidget(new ZwTextField(m_window.generic2_tf,ZLocUtils.t("Dialogs","BuriedTreasureUnlockBody"))) as ZwTextField;
         }
         if(this.m_treasure != null)
         {
            treasureItem = this.m_treasure.getItem();
            if(treasureItem != null)
            {
               treasureFrame = new ZwFrame(m_window.treasure_mc);
               addWidget(new ObjectPreviewFrame(m_window.treasure_mc.icon_mc,treasureItem,null,null,[PREVIEW_WIDTH],"","",null,new Point(10,10))) as ObjectPreviewFrame;
               addWidget(treasureFrame);
               if(treasureItem.cash > 0)
               {
                  addWidget(new FarmAnimatedCashButton(m_window.buy_bt,ZLocUtils.t("Dialogs","BuriedTreasure_Unlock"),treasureItem.cash.toString(),this.onFCBuriedTreasureOpen)) as FarmAnimatedTextButton;
               }
               else
               {
                  addWidget(new FarmAnimatedTextButton(m_window.open_bt,ZLocUtils.t("Dialogs","BuriedTreasure_Unlock"),this.onBuriedTreasureOpen)) as FarmAnimatedTextButton;
               }
            }
            FarmStatsManager.count(BuriedTreasureManager.BURIED_TREASURE_COUNTER,"view_dialog ");
         }
      }
      
      private function onFCBuriedTreasureOpen(event:Event) : void
      {
         var treasure:FarmItem = null;
         var treasurePrice:String = null;
         var message:String = null;
         if(this.m_treasure != null)
         {
            treasure = this.m_treasure.getItem();
            if(treasure != null)
            {
               treasurePrice = treasure.cash.toString();
               message = ZLocUtils.t("Dialogs","BuriedTreasure_confirmpurchase",{"price":treasurePrice});
               this.m_dialog = UI.showMessage(message,UI.BUTTON_LAYOUT_ACCEPT,null,null,true,this.onBuriedTreasureOpen);
            }
         }
      }
      
      private function onBuriedTreasureOpen(event:Event) : void
      {
         BuriedTreasureManager.instance.onBuriedTreasureOpen(this.m_treasure);
         close();
         BuriedTreasureManager.instance.showTreasureRewardToaster();
         BuriedTreasureManager.instance.hideTreasureObject(this.m_treasure);
         if(this.m_dialog)
         {
            this.m_dialog.destroy();
         }
      }
      
      override protected function onClose(event:Event) : void
      {
         BuriedTreasureManager.instance.onBuriedTreasureIgnored(this.m_treasure);
         super.onClose(event);
         BuriedTreasureManager.instance.hideTreasureObject(this.m_treasure);
         if(this.m_dialog)
         {
            this.m_dialog.destroy();
         }
      }
   }
}


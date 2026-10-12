package Widgets.Windows
{
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.FreeGiftsSlotContainerFrame;
   import flash.events.Event;
   
   public class CustomFreeGiftSelectionWindow extends FarmWindow
   {
      
      private static const ASSET_URL:String = "assets/dialogs/FV_flashFreeGifts.swf";
      
      public static const SEND_FREE_GIFT:String = "send_free_gift";
      
      private var m_slotContainerFrame:FreeGiftsSlotContainerFrame = null;
      
      private var m_loadingSpinner:ZwWidget = null;
      
      protected var m_freeGifts:Array = new Array();
      
      public function CustomFreeGiftSelectionWindow(freeGiftNames:Array)
      {
         super(ASSET_URL);
         this.setUpFreeGifts(freeGiftNames);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         addWidget(new ZwTextField(m_window.txt_header,ZLocUtils.t("Dialogs","FreeGiftsSelection_Title")));
         addWidget(new ZwTextField(m_window.txt_body,ZLocUtils.t("Dialogs","FreeGiftsSelection_Subtitle")));
         addWidget(new ZwWidget(m_window.mc_background));
         addWidget(new ZwWidget(m_window.mc_scene));
         this.m_slotContainerFrame = addWidget(new FreeGiftsSlotContainerFrame(m_window.slotContainer_mc,this.m_freeGifts,SEND_FREE_GIFT,this),true) as FreeGiftsSlotContainerFrame;
         this.m_slotContainerFrame.update();
      }
      
      override protected function release() : void
      {
         super.release();
         this.m_slotContainerFrame = null;
      }
      
      override protected function onClose(event:Event) : void
      {
         this.m_slotContainerFrame = null;
         super.onClose(event);
      }
      
      public function setUpFreeGifts(freeGiftNames:Array) : void
      {
         var itemName:String = null;
         var farmItem:FarmItem = null;
         for each(itemName in freeGiftNames)
         {
            farmItem = Global.farmGameSettingsManager.getFarmItemByName(itemName);
            if(farmItem.giftable)
            {
               this.m_freeGifts.push(farmItem);
            }
         }
      }
      
      public function closeWindow() : void
      {
         this.close();
      }
   }
}


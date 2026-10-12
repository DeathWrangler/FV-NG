package Display
{
   import Classes.util.ZLocUtils;
   import Engine.Managers.LoadingManager;
   import Engine.Utilities;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class SpecialDeliveryBoxShowRewardDialog extends SlotDialog
   {
      
      private const NUM_SLOTS:int = 5;
      
      private var m_quantity:int;
      
      private var m_totalGiftPrices:Number;
      
      private var m_itemObject:Object;
      
      private var m_result:Object;
      
      private var m_usedTypes:Object = null;
      
      public function SpecialDeliveryBoxShowRewardDialog(result:Object, quantity:int)
      {
         this.m_result = result;
         this.m_quantity = quantity;
         m_dialogAsset = "assets/dialogs/FV_openAll_SDB.swf";
         super();
      }
      
      override protected function getNumSlots() : int
      {
         return this.NUM_SLOTS;
      }
      
      override protected function onLoadComplete() : void
      {
         super.onLoadComplete();
         this.m_itemObject = new Object();
         m_window.openAll_SBD_mc.arrowButtonLeft_mc.addEventListener(MouseEvent.CLICK,onLtArrowClick);
         m_window.openAll_SBD_mc.arrowButtonRight_mc.addEventListener(MouseEvent.CLICK,onRtArrowClick);
         var okBtn:FarmAnimatedTextButton = new FarmAnimatedTextButton(m_window.openAll_SBD_mc.okay_bt,ZLocUtils.t("Dialogs","Okay"),this.onOkayClick);
         m_tiles.push(m_window.openAll_SBD_mc.giftPanel1,m_window.openAll_SBD_mc.giftPanel2,m_window.openAll_SBD_mc.giftPanel3,m_window.openAll_SBD_mc.giftPanel4,m_window.openAll_SBD_mc.giftPanel5);
         removeTiles();
         this.pushNewData();
         var compIdx:int = 0;
         while(compIdx < this.NUM_SLOTS && compIdx < m_data.length)
         {
            this.addComponent(compIdx);
            compIdx++;
         }
         m_window.openAll_SBD_mc.title_tf.text = ZLocUtils.t("Dialogs","UseAll_DialogTitle");
         m_window.openAll_SBD_mc.generic_tf.text = ZLocUtils.t("Dialogs","UseAll_DialogTagline",{"quantity":this.m_quantity});
      }
      
      private function onOkayClick(event:MouseEvent) : void
      {
         UI.displayGiftBoxWindow();
         close();
      }
      
      private function pushNewData() : void
      {
         var objectIdx:int = 0;
         m_data = [];
         m_tileSet = 0;
         if(this.m_result.length > 0)
         {
            for(objectIdx = 0; objectIdx < this.m_result.length; objectIdx++)
            {
               m_data.push(this.m_result[objectIdx]);
            }
         }
         this.fixArrows();
      }
      
      override protected function fixArrows() : void
      {
         m_window.openAll_SBD_mc.arrowButtonLeft_mc.visible = m_tileSet > 0 ? true : false;
         var isRightArrowActive:Boolean = false;
         if((m_tileSet + 1) * this.getNumSlots() < m_data.length)
         {
            isRightArrowActive = true;
         }
         else
         {
            isRightArrowActive = false;
         }
         m_window.openAll_SBD_mc.arrowButtonRight_mc.visible = isRightArrowActive;
      }
      
      override protected function addComponent(compId:int, index:int = 0) : void
      {
         var giftInfoCard:MovieClip = null;
         var item:Object = null;
         var url:String = null;
         var icon:Loader = null;
         if(Boolean(m_tiles) && m_data[index + compId] != null)
         {
            giftInfoCard = m_tiles[compId] as MovieClip;
            item = m_data[index + compId];
            giftInfoCard.giftAmount_tf.text = ZLocUtils.t("Dialogs","UseAll_DialogQuantity",{"quantity":item.quantity});
            giftInfoCard.itemTitle_tf.text = ZLocUtils.tk_pk_asTitle(item.friendlyName);
            giftInfoCard.visible = true;
            url = item.iconUrl;
            icon = LoadingManager.load(url,function(event:Event):void
            {
               var dispObj:* = undefined;
               if(Boolean(icon) && Boolean(icon.content))
               {
                  if(giftInfoCard)
                  {
                     Utilities.removeAllChildren(giftInfoCard.icon);
                  }
                  dispObj = icon.content;
                  dispObj.width = 50;
                  dispObj.height = 50;
                  giftInfoCard.icon.addChild(dispObj);
               }
            });
         }
      }
   }
}


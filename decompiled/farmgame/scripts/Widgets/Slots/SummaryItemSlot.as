package Widgets.Slots
{
   import Classes.ZItem.FarmItem;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.display.MovieClip;
   
   public class SummaryItemSlot extends ZwFrame
   {
      
      private var m_quantityText:ZwTextField;
      
      private var m_quantity:int = 1;
      
      private var m_giftImage:ZwFrame;
      
      public function SummaryItemSlot(element:MovieClip, frame:uint, itemInfo:String, infoType:String)
      {
         var giftItem:FarmItem = null;
         super(element);
         element.effect_mc.visible = false;
         element.visible = true;
         this.m_giftImage = addWidget(new ZwFrame(element.reward_mc)) as ZwFrame;
         this.m_giftImage.element.gotoAndStop(frame);
         if(infoType == "code")
         {
            giftItem = Global.farmGameSettingsManager.getFarmItemByCode(itemInfo);
         }
         else if(infoType == "name")
         {
            giftItem = Global.farmGameSettingsManager.getFarmItemByName(itemInfo);
         }
         var name:String = giftItem.friendlyTitle;
         this.m_giftImage.attachTooltip(new FarmTextTooltip(name));
         element.image_mc.visible = false;
         this.m_quantityText = addWidget(new ZwTextField(element.count_tf,"x1")) as ZwTextField;
      }
      
      public function incrementQuantity() : void
      {
         ++this.m_quantity;
         this.m_quantityText.text = "x" + this.m_quantity;
      }
   }
}


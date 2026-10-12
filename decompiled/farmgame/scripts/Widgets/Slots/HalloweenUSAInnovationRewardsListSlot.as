package Widgets.Slots
{
   import Classes.ZItem.FarmItem;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Frames.ObjectPreviewFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   
   public class HalloweenUSAInnovationRewardsListSlot extends ZwSlotFrame
   {
      
      private var m_featureName:String;
      
      private var m_isIconPreviewAdded:Boolean = false;
      
      protected var m_iconPreview:ObjectPreviewFrame;
      
      private var m_toolTip:FarmTextTooltip;
      
      public function HalloweenUSAInnovationRewardsListSlot(element:DisplayObject, featureName:String)
      {
         this.m_featureName = featureName;
         super(element);
      }
      
      override public function populate(data:Object) : void
      {
         super.populate(data);
         var item:FarmItem = Global.farmGameSettingsManager.getFarmItemByCode(data.code);
         var icon:FarmIcon = new FarmIcon(m_element as MovieClip,item.iconUrl);
         icon.detachTooltip();
         if(this.m_toolTip)
         {
            this.m_toolTip.setText(item.friendlyTitle);
         }
         else
         {
            icon.attachTooltip(this.m_toolTip = new FarmTextTooltip(item.friendlyTitle));
         }
         icon.visible = true;
      }
   }
}


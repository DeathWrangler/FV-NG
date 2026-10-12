package Widgets.Slots
{
   import Classes.ZItem.FarmItem;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Frames.ObjectPreviewFrame;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   
   public class SubscriberWalletMainWindowRewardSlot extends ZwSlotFrame
   {
      
      private var m_featureName:String;
      
      protected var m_iconPreview:ObjectPreviewFrame;
      
      public function SubscriberWalletMainWindowRewardSlot(element:DisplayObject, featureName:String)
      {
         super(element);
         this.m_featureName = featureName;
      }
      
      override public function populate(data:Object) : void
      {
         super.populate(data);
         var item:FarmItem = Global.farmGameSettingsManager.getFarmItemByCode(data.rewardItemName);
         if(item)
         {
            (m_element as MovieClip).visible = true;
            if(m_element.hasOwnProperty("bounds_mc"))
            {
               addWidget(this.m_iconPreview = new ObjectPreviewFrame(m_element["bounds_mc"],item,null,null,[m_element["bounds_mc"]["width"]]),true);
               this.m_iconPreview.attachTooltip(new FarmTextTooltip(item.friendlyTitle));
               this.m_iconPreview.visible = true;
            }
         }
      }
   }
}


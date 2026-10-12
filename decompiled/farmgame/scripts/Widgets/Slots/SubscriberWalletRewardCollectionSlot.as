package Widgets.Slots
{
   import Classes.ZItem.FarmItem;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Frames.ObjectPreviewFrame;
   import Widgets.Frames.SubscriberWalletRewardCollectionFrame;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   
   public class SubscriberWalletRewardCollectionSlot extends ZwSlotFrame
   {
      
      private var m_featureName:String;
      
      private var m_isIconPreviewAdded:Boolean = false;
      
      protected var m_iconPreview:ObjectPreviewFrame;
      
      public function SubscriberWalletRewardCollectionSlot(element:DisplayObject, featureName:String, windowPageFrame:SubscriberWalletRewardCollectionFrame)
      {
         super(element);
         this.m_featureName = featureName;
         this.m_isIconPreviewAdded = false;
      }
      
      override public function populate(data:Object) : void
      {
         super.populate(data);
         var item:FarmItem = Global.farmGameSettingsManager.getFarmItemByCode(data.rewardItemName);
         if(this.m_isIconPreviewAdded == true)
         {
            removeWidget(this.m_iconPreview);
            this.m_iconPreview.detachTooltip();
         }
         addWidget(this.m_iconPreview = new ObjectPreviewFrame(m_element["icon_mc"],item,null,null,[100]),true);
         var toolTip:String = item.friendlyTitle;
         if(data.hasOwnProperty("rewardType") && data["rewardType"] == "ultrarare")
         {
            toolTip += " (Increase Mastery to transform this animal!)";
         }
         this.m_iconPreview.attachTooltip(new FarmTextTooltip(toolTip));
         this.m_isIconPreviewAdded = true;
         if(data.hasOwnProperty("old") && Boolean(m_element["newTag_mc"]))
         {
            (m_element["newTag_mc"] as MovieClip).visible = !data["old"];
         }
      }
   }
}


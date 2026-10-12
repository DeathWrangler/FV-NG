package Widgets.Slots
{
   import Classes.ZItem.FarmItem;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Frames.ObjectPreviewFrame;
   import Widgets.Frames.SubscriberWalletRewardCollectionNewRewardsFrame;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   
   public class SubscriberWalletRewardCollectionNewRewardSlot extends ZwSlotFrame
   {
      
      private var m_featureName:String;
      
      private var m_isIconPreviewAdded:Boolean = false;
      
      protected var m_iconPreview:ObjectPreviewFrame;
      
      public function SubscriberWalletRewardCollectionNewRewardSlot(element:DisplayObject, featureName:String, windowPageFrame:SubscriberWalletRewardCollectionNewRewardsFrame)
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
         this.m_iconPreview.attachTooltip(new FarmTextTooltip(item.friendlyTitle));
         this.m_isIconPreviewAdded = true;
         (m_element["superRareTag"] as MovieClip).visible = false;
         (m_element["UltraRareTag"] as MovieClip).visible = false;
         (m_element["RareTag"] as MovieClip).visible = false;
         if(data.hasOwnProperty("rewardType"))
         {
            if("superrare" == data.rewardType)
            {
               (m_element["superRareTag"] as MovieClip).visible = true;
            }
            else if("ultrarare" == data.rewardType)
            {
               (m_element["UltraRareTag"] as MovieClip).visible = true;
            }
            else if("rare" == data.rewardType)
            {
               (m_element["RareTag"] as MovieClip).visible = true;
            }
         }
      }
   }
}


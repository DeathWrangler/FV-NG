package Widgets.Slots
{
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   
   public class BoraBoraInnovationRewardsPageSlot extends ZwSlotFrame
   {
      
      private var m_featureName:String;
      
      private var m_rewardIcon:FarmIcon;
      
      private var m_thumbsCount:int;
      
      private var m_thumbs_tf:ZwTextField;
      
      private var m_checkmark_mc:MovieClip;
      
      private var m_totalStars:int;
      
      public function BoraBoraInnovationRewardsPageSlot(element:DisplayObject, featureName:String, totalStars:int)
      {
         super(element);
         this.m_featureName = featureName;
         this.m_totalStars = totalStars;
         if(m_element.hasOwnProperty("reward_icon_mc"))
         {
            addWidget(this.m_rewardIcon = new FarmIcon(m_element["reward_icon_mc"]));
            this.m_rewardIcon.visible = true;
         }
         if(m_element.hasOwnProperty("thumbs_up_count_tf"))
         {
            addWidget(this.m_thumbs_tf = new ZwTextField(m_element["thumbs_up_count_tf"]));
         }
         if(m_element.hasOwnProperty("checkmark_mc"))
         {
            this.m_checkmark_mc = m_element["checkmark_mc"] as MovieClip;
            this.m_checkmark_mc.visible = false;
         }
      }
      
      override public function populate(data:Object) : void
      {
         super.populate(data);
         this.m_thumbsCount = data["thumbsUp"] as int;
         if(this.m_rewardIcon)
         {
            this.m_rewardIcon.loadIcon(data["iconUrl"]);
            this.m_rewardIcon.setIconSize(50,50);
            this.m_rewardIcon.detachTooltip();
            this.m_rewardIcon.attachTooltip(new FarmTextTooltip(data["rewardName"]));
            this.m_rewardIcon.visible = true;
         }
         if(this.m_thumbs_tf)
         {
            this.m_thumbs_tf.text = this.m_thumbsCount.toString();
            this.m_thumbs_tf.visible = true;
         }
         this.m_checkmark_mc.visible = false;
         if(this.m_thumbsCount <= this.m_totalStars)
         {
            this.m_checkmark_mc.visible = true;
         }
      }
   }
}


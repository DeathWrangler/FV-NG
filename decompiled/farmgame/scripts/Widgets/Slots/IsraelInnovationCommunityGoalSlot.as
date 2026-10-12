package Widgets.Slots
{
   import Classes.ZItem.FarmItem;
   import Managers.IsraelInnovationManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.FarmTextTooltip;
   import Widgets.Windows.GenericSingleRewardPopup;
   import Widgets.Windows.IsraelInnovationCommunityGoalWindow;
   import com.greensock.TweenMax;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   
   public class IsraelInnovationCommunityGoalSlot extends ZwSlotFrame
   {
      
      private var m_featureName:String;
      
      private var m_data:Object;
      
      private var m_window:IsraelInnovationCommunityGoalWindow;
      
      private var m_rewardPopup:GenericSingleRewardPopup;
      
      private var m_checkmarkMc:MovieClip;
      
      private var m_titleTf:ZwTextField;
      
      private var m_conTf:ZwTextField;
      
      private var m_eligibilityTf:ZwTextField;
      
      private var m_highlightMc:MovieClip;
      
      private var m_lockMc:MovieClip;
      
      private var m_progressBarMc:MovieClip;
      
      private var m_percentTf:ZwTextField;
      
      private var m_prizeMc:FarmIcon;
      
      private var m_hitWidget1:ZwWidget;
      
      private var m_nameTf:ZwTextField;
      
      private var m_consumableMc:MovieClip;
      
      private var m_iconMc:FarmIcon;
      
      private var m_countTf:ZwTextField;
      
      private var m_overlayMc:MovieClip;
      
      private var m_messageTf:ZwTextField;
      
      private var m_timerTf:ZwTextField;
      
      private var m_item:FarmItem;
      
      private var m_itemBox:FarmIcon;
      
      private var m_redeemBt:FarmAnimatedTextButton;
      
      private const PROGRESS_BAR_FULL_WIDTH:int = 246;
      
      public function IsraelInnovationCommunityGoalSlot(featureName:String, element:DisplayObject, window:IsraelInnovationCommunityGoalWindow)
      {
         this.m_featureName = featureName;
         this.m_window = window;
         super(element);
         if(m_element.hasOwnProperty("check_mc"))
         {
            this.m_checkmarkMc = m_element["check_mc"] as MovieClip;
         }
         if(m_element.hasOwnProperty("con_tf"))
         {
            this.m_conTf = new ZwTextField(m_element["con_tf"]);
         }
         if(m_element.hasOwnProperty("eligibility_tf"))
         {
            this.m_eligibilityTf = new ZwTextField(m_element["eligibility_tf"]);
         }
         if(m_element.hasOwnProperty("highlight_mc"))
         {
            this.m_highlightMc = m_element["highlight_mc"] as MovieClip;
         }
         if(m_element.hasOwnProperty("icon_mc"))
         {
            addWidget(this.m_iconMc = new FarmIcon(m_element["icon_mc"]));
         }
         if(m_element.hasOwnProperty("lock_mc"))
         {
            this.m_lockMc = m_element["lock_mc"] as MovieClip;
            this.m_lockMc.visible = true;
         }
         if(m_element.hasOwnProperty("meter_mc"))
         {
            this.m_progressBarMc = m_element["meter_mc"] as MovieClip;
            this.updateProgressBar(0,1);
            this.m_progressBarMc.visible = true;
         }
         if(m_element.hasOwnProperty("percent_tf"))
         {
            this.m_percentTf = new ZwTextField(m_element["percent_tf"],"0%");
            this.m_percentTf.visible = true;
         }
         if(m_element.hasOwnProperty("title_tf"))
         {
            this.m_titleTf = new ZwTextField(m_element["title_tf"]);
            this.m_titleTf.visible = true;
         }
         if(m_element.hasOwnProperty("prize_mc"))
         {
            addWidget(this.m_prizeMc = new FarmIcon(m_element["prize_mc"]));
         }
      }
      
      override public function populate(data:Object) : void
      {
         var rewardItem1:FarmItem = null;
         var rewardQty1:int = 0;
         var iconUrl1:String = null;
         var rewardItem2:FarmItem = null;
         var rewardQty2:int = 0;
         var iconUrl2:String = null;
         this.m_data = data;
         super.populate(data);
         if(this.m_data)
         {
            if(this.m_data.slotNumber == 0)
            {
               if(this.m_titleTf)
               {
                  this.m_titleTf.text = "Together finish " + this.m_data.communityGoal + " tasks on the Orderboard this week!";
                  this.m_titleTf.visible = true;
               }
               if(this.m_conTf)
               {
                  this.m_conTf.text = "Your contribution: " + this.m_data.playerProg;
                  this.m_conTf.visible = true;
               }
               if(this.m_eligibilityTf)
               {
                  if(this.m_data.playerProg > 0)
                  {
                     this.m_eligibilityTf.text = "You must finish " + (this.m_data.playerGoal - this.m_data.playerProg) + " more tasks to qualify";
                  }
                  else
                  {
                     this.m_eligibilityTf.text = "You must finish " + (this.m_data.playerGoal - this.m_data.playerProg) + " tasks to qualify";
                  }
               }
               if(this.m_prizeMc)
               {
                  rewardItem1 = Global.farmGameSettingsManager.getFarmItemByName(this.m_data.rewardName);
                  rewardQty1 = int(this.m_data.rewardQuantity);
                  if(rewardItem1)
                  {
                     iconUrl1 = rewardItem1.getImageByName(FarmItem.ICON_FEED);
                     this.m_prizeMc.loadIcon(iconUrl1);
                     this.m_prizeMc.setIconSize(70,70);
                     this.m_prizeMc.setSmoothing(true);
                     this.m_prizeMc.visible = true;
                     this.m_prizeMc.attachTooltip(new FarmTextTooltip(rewardQty1.toString() + " " + rewardItem1.friendlyTitle));
                  }
               }
               if(this.m_iconMc)
               {
                  this.m_iconMc.loadIcon("assets/dialogs/israel/innovation/icon_points.png");
                  this.m_iconMc.visible = true;
               }
            }
            if(this.m_data.slotNumber == 1)
            {
               if(this.m_titleTf)
               {
                  this.m_titleTf.text = "Together get or give " + this.m_data.communityGoal + " Bundles of plenty this week!";
                  this.m_titleTf.visible = true;
               }
               if(this.m_conTf)
               {
                  this.m_conTf.text = "Your contribution: " + this.m_data.playerProg;
                  this.m_conTf.visible = true;
               }
               if(this.m_eligibilityTf)
               {
                  if(this.m_data.playerProg > 0)
                  {
                     this.m_eligibilityTf.text = "You must ask or give " + (this.m_data.playerGoal - this.m_data.playerProg) + " more Bundles of plenty this week!";
                  }
                  else
                  {
                     this.m_eligibilityTf.text = "You must ask or give " + (this.m_data.playerGoal - this.m_data.playerProg) + " Bundles of plenty this week!";
                  }
               }
               if(this.m_prizeMc)
               {
                  rewardItem2 = Global.farmGameSettingsManager.getFarmItemByName(this.m_data.rewardName);
                  rewardQty2 = int(this.m_data.rewardQuantity);
                  if(rewardItem2)
                  {
                     iconUrl2 = rewardItem2.getImageByName(FarmItem.ICON_FEED);
                     this.m_prizeMc.loadIcon(iconUrl2);
                     this.m_prizeMc.setIconSize(70,70);
                     this.m_prizeMc.setSmoothing(true);
                     this.m_prizeMc.visible = true;
                     this.m_prizeMc.attachTooltip(new FarmTextTooltip(rewardQty2.toString() + " " + rewardItem2.friendlyTitle));
                  }
               }
               if(this.m_iconMc)
               {
                  this.m_iconMc.loadIcon("assets/newsfeed/xis_bundleofplenty.png");
                  this.m_iconMc.visible = true;
               }
            }
            if(this.m_data.communityProg)
            {
               this.updateProgressBar(this.m_data.communityProg,this.m_data.communityGoal);
               if(this.m_percentTf)
               {
                  this.m_percentTf.text = Math.floor(this.m_data.communityProg / this.m_data.communityGoal * 100) + "%";
               }
            }
            if(this.m_data.playerGoal > this.m_data.playerProg)
            {
               this.m_lockMc.visible = true;
            }
            else
            {
               this.m_lockMc.visible = false;
            }
            if(this.m_data.playerGoal > this.m_data.playerProg)
            {
               this.m_eligibilityTf.visible = true;
            }
            else
            {
               this.m_eligibilityTf.visible = false;
               if(!this.manager.isCommGoalRewardGranted(this.m_data.taskName,1))
               {
                  this.m_window.checkForCommunityGoalReward();
               }
            }
            if(this.manager.isCommGoalRewardGranted(this.m_data.taskName,1))
            {
               this.m_highlightMc.visible = true;
               this.m_checkmarkMc.visible = true;
            }
         }
      }
      
      private function updateProgressBar(percentValue:Number, goal:Number) : void
      {
         percentValue = Math.floor(percentValue / goal * 100);
         if(percentValue > 100)
         {
            percentValue = 100;
         }
         var barWidth:Number = percentValue * this.PROGRESS_BAR_FULL_WIDTH / 100;
         if(this.m_progressBarMc.bar_mc)
         {
            if(percentValue == 0)
            {
               (this.m_progressBarMc.bar_mc as MovieClip).width = barWidth;
            }
            else
            {
               TweenMax.to(this.m_progressBarMc.bar_mc,2,{"width":barWidth});
            }
         }
      }
      
      private function get manager() : IsraelInnovationManager
      {
         return IsraelInnovationManager.getInstance(this.m_featureName);
      }
   }
}


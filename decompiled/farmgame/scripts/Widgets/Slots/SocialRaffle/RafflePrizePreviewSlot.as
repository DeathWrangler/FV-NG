package Widgets.Slots.SocialRaffle
{
   import Classes.util.ZLocUtils;
   import Managers.SocialRaffleManager;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.TextFields.FarmTextField;
   import Widgets.Tooltips.MovieClipWithTextTooltip;
   import Widgets.Windows.SocialRaffle.SocialRaffleWindow;
   import com.greensock.TweenLite;
   import flash.display.DisplayObject;
   
   public class RafflePrizePreviewSlot extends ZwSlotFrame
   {
      
      private var m_defaultOdds:FarmTextField = null;
      
      private var m_prizeImage:FarmIcon = null;
      
      private var m_hasAnimated:Boolean = false;
      
      private var m_oddsAsText:Array = null;
      
      private var m_oddsAsTextThresholds:Array = null;
      
      private var m_yourOddsAsTextThresholds:Array = null;
      
      private var m_yourOddsAsText:Array = null;
      
      private var m_checkmark:ZwFrame = null;
      
      private var m_xmark:ZwFrame = null;
      
      private var m_background:ZwFrame = null;
      
      private var m_quantityFrame:ZwFrame = null;
      
      private var m_quantity:FarmTextField = null;
      
      public function RafflePrizePreviewSlot(element:DisplayObject)
      {
         super(element);
         if(this.element.quantity_mc)
         {
            this.m_quantityFrame = new ZwFrame(this.element.quantity_mc);
            this.m_quantity = new FarmTextField(this.m_quantityFrame.element.quantity_tf,"");
            this.m_quantityFrame.addWidget(this.m_quantity);
            addWidget(this.m_quantityFrame);
         }
         this.m_background = new ZwFrame(this.element.itemboxover_mc);
         this.addWidget(this.m_background);
         this.m_background.element.gotoAndStop(1);
         this.m_defaultOdds = new FarmTextField(this.element.defaultodds_tf,"");
         this.addWidget(this.m_defaultOdds);
         this.m_prizeImage = new FarmIcon(this.element.prizeimage_mc);
         this.addWidget(this.m_prizeImage);
         this.attachTooltip(new MovieClipWithTextTooltip(this.element.tooltip_mc,""));
         (m_tooltip as MovieClipWithTextTooltip).stationary = true;
         this.m_oddsAsTextThresholds = [1 / 25,1 / 200];
         this.m_oddsAsText = [ZLocUtils.t("Dialogs","socialrafflebuilding_odds_common"),ZLocUtils.t("Dialogs","socialrafflebuilding_odds_uncommon"),ZLocUtils.t("Dialogs","socialrafflebuilding_odds_rare")];
         this.m_yourOddsAsTextThresholds = [0.5,0.9];
         this.m_yourOddsAsText = [ZLocUtils.t("Dialogs","socialrafflebuilding_yourodds_low"),ZLocUtils.t("Dialogs","socialrafflebuilding_yourodds_medium"),ZLocUtils.t("Dialogs","socialrafflebuilding_yourodds_high")];
         if(this.element.hasOwnProperty("xmark_mc"))
         {
            this.m_xmark = addWidget(new ZwFrame(this.element.xmark_mc),false) as ZwFrame;
         }
         if(this.element.hasOwnProperty("checkmark_mc"))
         {
            this.m_checkmark = addWidget(new ZwFrame(this.element.checkmark_mc),false) as ZwFrame;
         }
      }
      
      public function toggleHighlight(highlighted:Boolean) : void
      {
         this.m_background.visible = true;
         if(highlighted)
         {
            this.m_background.element.gotoAndStop(2);
         }
         else
         {
            this.m_background.element.gotoAndStop(1);
         }
      }
      
      public function toggleRaffleResult(won:Boolean) : void
      {
         if(won)
         {
            this.m_checkmark.visible = true;
         }
         else
         {
            this.m_xmark.visible = true;
         }
      }
      
      override public function release() : void
      {
         TweenLite.killTweensOf(this.m_prizeImage);
         super.release();
      }
      
      override public function populate(data:Object) : void
      {
         var yourChance:Number = NaN;
         super.populate(data);
         this.m_background.visible = true;
         if(data)
         {
            if(data.reward.chance)
            {
               this.m_defaultOdds.text = ZLocUtils.t("Dialogs","socialrafflebuilding_main_mainodds",{"odds":SocialRaffleWindow.generateOddsString(data.reward.chance)});
               this.m_defaultOdds.visible = true;
            }
            if(Boolean(data.reward.qty) && Boolean(this.m_quantity) && data.reward.qty as int > 1)
            {
               this.m_quantity.text = "x" + (data.reward.qty as int).toString();
               this.m_quantityFrame.visible = true;
               this.m_quantity.visible = true;
            }
            else if(this.m_quantityFrame)
            {
               this.m_quantityFrame.visible = false;
            }
            if(data.reward.itemName)
            {
               this.m_prizeImage.loadIcon(Global.farmGameSettingsManager.getFarmItemByName(data.reward.itemName).iconRelativeUrl);
               this.m_prizeImage.setSmoothing(true);
               if(Global.animationState == Global.ANIMATION_STATE_PLAY && this.m_hasAnimated == false)
               {
                  TweenLite.from(this.m_prizeImage,3,{
                     "delay":0.5 + 0.2 * parseInt(data["slotNum"]),
                     "alpha":0
                  });
                  this.m_hasAnimated = true;
               }
               this.m_prizeImage.visible = true;
               (m_tooltip as MovieClipWithTextTooltip).text = ZLocUtils.t("Dialogs","socialrafflebuilding_main_prize",{"itemName":ZLocUtils.tk_pk_asTitle(Global.farmGameSettingsManager.getFarmItemByName(data.reward.itemName).friendlyName)});
            }
            if(Boolean(data.reward.itemName) && Boolean(data.reward.chance))
            {
               yourChance = data.reward.chance * SocialRaffleManager.getInstance().raffleDataView.getTotalNumTickets();
               (m_tooltip as MovieClipWithTextTooltip).text += "\n" + ZLocUtils.t("Dialogs","socialrafflebuilding_main_yourodds",{"odds":SocialRaffleWindow.generateOddsString(yourChance)});
            }
         }
      }
   }
}


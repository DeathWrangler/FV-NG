package Widgets.Windows.RegionAchievement
{
   import Classes.RegionAchievement.Region;
   import Classes.util.ZLocUtils;
   import Events.RegionAchievementEvent;
   import Managers.RegionAchievementManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class RegionAchievementShieldRewardFrame extends ZwFrame
   {
      
      private static const TITLE_TF:String = "title_tf";
      
      private static const BODY_TF:String = "body_tf";
      
      private static const TILE_TITLE_TF:String = "title1_tf";
      
      private static const TILE_DESC_TF:String = "body1_tf";
      
      private static const CONSTUME_DESC_TF:String = "body2_tf";
      
      private static const EXTRA_REWARD_TF:String = "body3_tf";
      
      private static const EXTRA_REWARD_COUNTER_TF:String = "counter_tf";
      
      private static const SHIPPING_TILE_TF:String = "title_tf";
      
      private static const SHIELD_ICON_MC:String = "icon_1_mc";
      
      private static const TILE_ICON_MC:String = "icon_0_mc";
      
      private static const COSTUME_ICON_MC:String = "icon_2_mc";
      
      private static const EXTRA_REWARD_MC:String = "icon_3_mc";
      
      private static const SPECIAL_TILE_MC:String = "specialtile_mc";
      
      private static const NPC_MC:String = "npc_mc";
      
      private static const SHIPPING_MC:String = "shipping_mc";
      
      private static const CHECKOUT_TILE_BT:String = "tileTutorial_bt";
      
      private var m_shppingMC:ZwFrame;
      
      private var m_title:ZwTextField;
      
      private var m_body:ZwTextField;
      
      private var m_subtitleTf:ZwTextField;
      
      private var m_tileDesc:ZwTextField;
      
      private var m_costumeDesc:ZwTextField;
      
      private var m_extraRewardDesc:ZwTextField;
      
      private var m_extraRewardCount:ZwTextField;
      
      private var m_shieldIcon:FarmIcon;
      
      private var m_costumeIcon:FarmIcon;
      
      private var m_extraRewardIcon:FarmIcon;
      
      private var m_tileIcon:MovieClip;
      
      private var m_npc_mc:MovieClip;
      
      private var m_specialTile_mc:MovieClip;
      
      private var m_checkoutTile_bt:FarmAnimatedTextButton;
      
      private var m_featureName:String;
      
      private var m_shippingTileTf:ZwTextField;
      
      private var m_shippingBodyTf:ZwTextField;
      
      private var m_window:RegionAchievementShieldRewardWindow;
      
      public function RegionAchievementShieldRewardFrame(element:DisplayObject, featureName:String, window:RegionAchievementShieldRewardWindow)
      {
         this.m_featureName = featureName;
         this.m_window = window;
         super(element);
         if(m_element.hasOwnProperty(TITLE_TF))
         {
            addWidget(this.m_title = new ZwTextField(m_element[TITLE_TF],ZLocUtils.t("Dialogs",this.m_featureName + "_congrats")),true);
         }
         if(m_element.hasOwnProperty(BODY_TF))
         {
            addWidget(this.m_body = new ZwTextField(m_element[BODY_TF],""));
         }
         if(m_element.hasOwnProperty(TILE_TITLE_TF))
         {
            addWidget(this.m_subtitleTf = new ZwTextField(m_element[TILE_TITLE_TF],""),true);
         }
         if(m_element.hasOwnProperty(TILE_DESC_TF))
         {
            addWidget(this.m_tileDesc = new ZwTextField(m_element[TILE_DESC_TF],""),true);
         }
         if(m_element.hasOwnProperty(EXTRA_REWARD_TF))
         {
            addWidget(this.m_extraRewardDesc = new ZwTextField(m_element[EXTRA_REWARD_TF],""),true);
         }
         if(m_element.hasOwnProperty(EXTRA_REWARD_COUNTER_TF))
         {
            addWidget(this.m_extraRewardCount = new ZwTextField(m_element[EXTRA_REWARD_COUNTER_TF],""),true);
            this.m_extraRewardCount.visible = false;
         }
         if(m_element.hasOwnProperty(CONSTUME_DESC_TF))
         {
            addWidget(this.m_costumeDesc = new ZwTextField(m_element[CONSTUME_DESC_TF],""),true);
         }
         if(m_element.hasOwnProperty(SHIELD_ICON_MC))
         {
            addWidget(this.m_shieldIcon = new FarmIcon(m_element[SHIELD_ICON_MC]) as FarmIcon);
         }
         if(m_element.hasOwnProperty(TILE_ICON_MC))
         {
            this.m_tileIcon = m_element[TILE_ICON_MC] as MovieClip;
            this.m_tileIcon.visible = true;
         }
         if(m_element.hasOwnProperty(COSTUME_ICON_MC))
         {
            addWidget(this.m_costumeIcon = new FarmIcon(m_element[COSTUME_ICON_MC]) as FarmIcon);
         }
         if(m_element.hasOwnProperty(EXTRA_REWARD_MC))
         {
            addWidget(this.m_extraRewardIcon = new FarmIcon(m_element[EXTRA_REWARD_MC]) as FarmIcon);
         }
         if(m_element.hasOwnProperty(CHECKOUT_TILE_BT))
         {
            this.m_checkoutTile_bt = addWidget(new FarmAnimatedTextButton(m_element[CHECKOUT_TILE_BT],"",this.onCheckOutTile),true) as FarmAnimatedTextButton;
         }
         if(m_element.hasOwnProperty(NPC_MC))
         {
            this.m_npc_mc = m_element[NPC_MC] as MovieClip;
         }
         if(m_element.hasOwnProperty(SPECIAL_TILE_MC))
         {
            this.m_specialTile_mc = m_element[SPECIAL_TILE_MC] as MovieClip;
         }
         if(m_element.hasOwnProperty(SHIPPING_MC))
         {
            this.m_shppingMC = addWidget(new ZwFrame(m_element[SHIPPING_MC]),true) as ZwFrame;
            if(this.m_shppingMC.element.hasOwnProperty(BODY_TF))
            {
               this.m_shippingBodyTf = this.m_shppingMC.addWidget(new ZwTextField(this.m_shppingMC.element[BODY_TF]," "),true) as ZwTextField;
            }
            if(this.m_shppingMC.element.hasOwnProperty(SHIPPING_TILE_TF))
            {
               this.m_shippingTileTf = this.m_shppingMC.addWidget(new ZwTextField(this.m_shppingMC.element[SHIPPING_TILE_TF]," "),true) as ZwTextField;
            }
         }
      }
      
      public function refresh(regionId:String) : void
      {
         var bodyText:String = null;
         var titleText:String = null;
         var region:Region = RegionAchievementManager.getInstance(this.m_featureName).getRegionById(regionId);
         region.showShieldRewardWindow = false;
         this.m_body.text = ZLocUtils.t("Dialogs",this.m_featureName + "_ShieldReward_body",{"milestone":region.numOfAchievementsCompleted()});
         this.m_subtitleTf.text = ZLocUtils.t("Dialogs",this.m_featureName + "_ShieldReward_subtitle",{"chestName":region.chestName});
         this.m_costumeDesc.text = region.costumeName;
         this.m_extraRewardDesc.text = region.extraRewardName;
         this.m_extraRewardCount.text = region.extraRewardQty.toString();
         this.m_shieldIcon.loadIcon(region.chestIcon);
         this.m_costumeIcon.loadIcon(region.costumeIcon);
         this.m_extraRewardIcon.loadIcon(region.extraRewardIcon);
         this.m_checkoutTile_bt.text = ZLocUtils.t("Dialogs",this.m_featureName + "_ShieldReward_cta",{"specialtile":region.specialTileName});
         this.m_tileIcon.gotoAndStop(region.id);
         if(this.m_shppingMC)
         {
            this.m_shppingMC.visible = true;
            bodyText = "";
            titleText = "";
            if(RegionAchievementManager.getInstance(this.m_featureName).isGotSpecialRewardFromFO())
            {
               bodyText = ZLocUtils.t("Dialogs",this.m_featureName + "_ShieldReward_shipping_won_body");
               titleText = ZLocUtils.t("Dialogs",this.m_featureName + "_ShieldReward_shipping_won_title");
            }
            else
            {
               bodyText = ZLocUtils.t("Dialogs",this.m_featureName + "_ShieldReward_shipping_body");
               titleText = ZLocUtils.t("Dialogs",this.m_featureName + "_ShieldReward_shipping_title");
            }
            this.m_shippingBodyTf.text = bodyText;
            this.m_shippingTileTf.text = titleText;
         }
      }
      
      private function onCheckOutTile(e:Event) : void
      {
         if(this.m_window)
         {
            this.m_window.close();
         }
         RegionAchievementManager.getInstance(this.m_featureName).dispatchRegionAchievementEvent(new RegionAchievementEvent(RegionAchievementEvent.EXECUTE_NEXT_ACTION));
      }
   }
}


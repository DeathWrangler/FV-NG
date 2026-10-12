package Widgets.Windows.RegionAchievement
{
   import Classes.RegionAchievement.Region;
   import Classes.util.ZLocUtils;
   import Managers.RegionAchievementManager;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   
   public class RegionAchievementTrophyFrame extends ZwFrame
   {
      
      private static const INCOMPLETE_STATE:int = 1;
      
      private static const COMPLETE_STATE:int = 2;
      
      public static const DEFAULT_TAB:String = "";
      
      private static const ICON_SIZE:int = 50;
      
      private static const TOTEM_MC:String = "shield_mc";
      
      private static const CHEST_MC:String = "tile_mc";
      
      private static const SHIPPING_MC:String = "shipping_mc";
      
      private static const BODY_TF:String = "body_tf";
      
      private static const TILE_TF:String = "body2_tf";
      
      private static const SHIPPING_TILE_TF:String = "title_tf";
      
      private static const COUNTER_TF:String = "counter_tf";
      
      private var m_chestIcon:FarmIcon;
      
      private var m_shppingMC:ZwFrame;
      
      private var m_bodyTf:ZwTextField;
      
      private var m_counterTf:ZwTextField;
      
      private var m_tileTf:ZwTextField;
      
      private var m_shippingTileTf:ZwTextField;
      
      private var m_shippingBodyTf:ZwTextField;
      
      private var m_specialTileMC:MovieClip;
      
      private var m_tabName:String;
      
      private var m_featureName:String;
      
      public function RegionAchievementTrophyFrame(element:DisplayObject, featureName:String, regionId:String = "")
      {
         super(element);
         this.m_tabName = regionId;
         this.m_featureName = featureName;
         if(m_element.hasOwnProperty(TOTEM_MC))
         {
            this.m_specialTileMC = m_element[TOTEM_MC] as MovieClip;
         }
         if(m_element.hasOwnProperty(CHEST_MC))
         {
            this.m_chestIcon = addWidget(new FarmIcon(m_element[CHEST_MC]),true) as FarmIcon;
         }
         if(m_element.hasOwnProperty(SHIPPING_MC))
         {
            this.m_shppingMC = addWidget(new ZwFrame(m_element[SHIPPING_MC]),true) as ZwFrame;
            if(this.m_shppingMC.element.hasOwnProperty(BODY_TF))
            {
               this.m_shippingBodyTf = addWidget(new ZwTextField(this.m_shppingMC.element[BODY_TF]," "),true) as ZwTextField;
            }
            if(this.m_shppingMC.element.hasOwnProperty(SHIPPING_TILE_TF))
            {
               this.m_shippingTileTf = addWidget(new ZwTextField(this.m_shppingMC.element[SHIPPING_TILE_TF]," "),true) as ZwTextField;
            }
         }
         if(m_element.hasOwnProperty(COUNTER_TF))
         {
            this.m_counterTf = addWidget(new ZwTextField(m_element[COUNTER_TF]," "),true) as ZwTextField;
         }
         if(m_element.hasOwnProperty(TILE_TF))
         {
            this.m_tileTf = addWidget(new ZwTextField(m_element[TILE_TF]," ")) as ZwTextField;
         }
         this.refresh(this.m_tabName);
      }
      
      public function refresh(tabName:String) : void
      {
         this.m_tabName = tabName;
         var selectedRegion:Region = RegionAchievementManager.getInstance(this.m_featureName).getRegionById(tabName);
         var isChampion:Boolean = RegionAchievementManager.getInstance(this.m_featureName).isChampionFromFO();
         var championSelectedRegionFrameOffset:int = isChampion ? 4 : 0;
         var frameNumber:int = int(selectedRegion.id) + championSelectedRegionFrameOffset;
         if(Boolean(selectedRegion && this.m_specialTileMC) && Boolean(this.m_chestIcon) && Boolean(m_element))
         {
            this.m_specialTileMC.visible = true;
            this.m_specialTileMC.gotoAndStop(frameNumber.toString());
            if(Boolean(this.m_counterTf) && Boolean(this.m_counterTf.element))
            {
               this.m_counterTf.text = this.getChestUlockDesc(selectedRegion);
            }
            if(Boolean(this.m_tileTf) && Boolean(this.m_tileTf.element))
            {
               this.m_tileTf.text = this.getTileDesc(selectedRegion);
            }
            (m_element as MovieClip).gotoAndStop(INCOMPLETE_STATE);
            if(selectedRegion.completed)
            {
               (m_element as MovieClip).gotoAndStop(COMPLETE_STATE);
            }
            this.m_chestIcon.loadIcon(selectedRegion.chestIcon);
            this.m_chestIcon.visible = true;
         }
      }
      
      public function getTileDesc(region:Region) : String
      {
         var result:String = "";
         if(region.shieldWon)
         {
            result = ZLocUtils.t("Dialogs",this.m_featureName + "_trophyroom_more_desc_won_" + region.id);
         }
         else
         {
            result = ZLocUtils.t("Dialogs",this.m_featureName + "_trophyroom_more_desc_" + region.id);
         }
         return result;
      }
      
      public function getChestUlockDesc(region:Region) : String
      {
         var result:String = "";
         var trophyRequired:int = region.shieldMilestone - region.numOfAchievementsCompleted();
         if(trophyRequired > 0)
         {
            result = ZLocUtils.t("Dialogs",this.m_featureName + "_trophyroom_Chest_Desc_" + region.id,{
               "milestone":trophyRequired.toString(),
               "regionName":region.name
            });
         }
         else
         {
            result = ZLocUtils.t("Dialogs",this.m_featureName + "_trophyroom_congrats",{"chestName":region.chestName});
         }
         return result;
      }
   }
}


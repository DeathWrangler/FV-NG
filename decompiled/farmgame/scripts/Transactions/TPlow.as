package Transactions
{
   import Classes.HarvestableResource;
   import Classes.Plot;
   import Classes.Terrain.TerrainUtil;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.GenericPopupTitle;
   import Display.UI;
   import Engine.Helpers.Vector2;
   import Engine.IsoMath;
   import Engine.Managers.TransactionManager;
   import Events.GenericPopupEvent;
   import Managers.FarmStatsManager;
   import com.adobe.crypto.MD5;
   import flash.geom.Point;
   
   public class TPlow extends TWorldState
   {
      
      private static const FUEL_DISCOVERY_OVERLAY_URL:String = "assets/overlays/effect_fuel_burst.swf";
      
      private static const FUEL_DISCOVERY_OWN_FARM_FEATURE_NAME:String = "lastFuelDiscoveryOwnFarm";
      
      private static const FUEL_CAN_DISCOVERY_IMAGE_URL:String = "assets/hud/fuelCanTall_100x100.png";
      
      public static const ACTION_PLOW:String = "plow";
      
      protected var m_energy:int = 0;
      
      protected var m_energySource:int;
      
      protected var m_energyMetadata:Object = null;
      
      protected var m_neighborId:String = "";
      
      private var m_tileX:int;
      
      private var m_tileY:int;
      
      public function TPlow(plot:Plot, energySource:int = 0, energy:int = 0, energyMetadata:Object = null, neighborId:String = "0")
      {
         var curTimeSecs:Number = NaN;
         var screen:Vector2 = null;
         this.m_energySource = HarvestableResource.ENERGY_SOURCE_AVATAR;
         this.m_energy = Math.max(energy,0);
         this.m_energySource = energySource;
         this.m_energyMetadata = energyMetadata;
         this.m_neighborId = neighborId;
         this.m_tileX = plot.getPosition().x;
         this.m_tileY = plot.getPosition().y;
         var gold:int = Global.player.gold;
         var fbID:String = Global.player.uid;
         var concatStr:String = fbID.toString() + gold.toString() + this.m_tileX.toString() + this.m_tileY.toString();
         var hexVal:String = MD5.hash(concatStr);
         var hexDigits:int = 7;
         var decVal:int = parseInt("0x" + hexVal.substr(-hexDigits)) % 1000;
         var fuelDiscoverProbability:Number = Global.farmGameSettingsManager.getNumber("fuelDiscoverProbability") * 1000;
         if(decVal < fuelDiscoverProbability)
         {
            curTimeSecs = GlobalEngine.serverTime / 1000;
            if(this.shouldDiscoverFuel(curTimeSecs))
            {
               Global.player.setFeatureLastShown(FUEL_DISCOVERY_OWN_FARM_FEATURE_NAME,curTimeSecs,false);
               screen = IsoMath.tilePosToPixelPos(plot.getPosition().x,plot.getPosition().y,plot.getPosition().z);
               Global.ui.displayOverlaySWF(Global.getAssetURL(FUEL_DISCOVERY_OVERLAY_URL),new Point(screen.x - plot.getActualDisplayObjectSize().x / 8,screen.y - plot.getActualDisplayObjectSize().y / 3));
            }
         }
         super(plot);
      }
      
      override public function perform() : void
      {
         signedWorldAction(ACTION_PLOW,{
            "energySource":this.m_energySource,
            "energyCost":this.m_energy,
            "energyMetadata":this.m_energyMetadata,
            "neighborId":this.m_neighborId
         });
      }
      
      override protected function onComplete(result:Object) : void
      {
         var fuelDiscoveryPopup:GenericPopupTitle = null;
         if(GlobalEngine.isFlashVarSetAndTrue("OPS_TEMPID_ON_PLOTS_TMPRT"))
         {
            super.onComplete(result);
         }
         if(Boolean(result.data) && Boolean(result.data.fuelDiscoveryRewardLink))
         {
            fuelDiscoveryPopup = new GenericPopupTitle("Congratulations","FuelDiscoveryOwnFarmFeedPrompt",false,GenericPopup.TYPE_SHARECANCEL,this.onFuelDiscoveryPromptClick);
            fuelDiscoveryPopup.setTrackerKey("fuel-friendHelp");
            fuelDiscoveryPopup.rewardUrl = result.data.fuelDiscoveryRewardLink;
            fuelDiscoveryPopup.setIcons(Global.getAssetURL(FUEL_CAN_DISCOVERY_IMAGE_URL),Global.getAssetURL(FUEL_CAN_DISCOVERY_IMAGE_URL));
            if(UI.shouldBlockPopupForRetention())
            {
               UI.handlePopupDisplayForRetention(ZLocUtils.t("Dialogs","FuelDiscoveryOwnFarmFeedPrompt"),GenericPopup.TYPE_SHARE,this.onFuelDiscoveryPromptClick,Global.getAssetURL(FUEL_CAN_DISCOVERY_IMAGE_URL),"",null);
            }
            else
            {
               Global.popupManager.addInactiveUserPopup(fuelDiscoveryPopup);
            }
         }
      }
      
      protected function onFuelDiscoveryPromptClick(event:GenericPopupEvent) : void
      {
         var bundleData:Object = null;
         if(event.button == GenericPopup.ACCEPT)
         {
            bundleData = {
               "reward_link":event.rewardLink,
               "images":[{
                  "href":"{SN_APP_URL}" + event.rewardLink,
                  "src":Global.getAssetURL("assets/newsfeed/givefuel_feed.png")
               }]
            };
            GlobalEngine.socialNetwork.publishFeedStory("feed_fuel_find_ownfarm",bundleData,[],false);
            FarmStatsManager.featureSample("Fuel","Disc_Own_Farm","Feeds_Shown","Accept");
         }
         else
         {
            FarmStatsManager.featureSample("Fuel","Disc_Own_Farm","Feeds_Shown","Cancel");
            TransactionManager.addTransaction(new TCancelFriendReward([event.rewardLink]));
         }
      }
      
      private function shouldDiscoverFuel(curTime:Number) : Boolean
      {
         var timeSinceLastFuelDiscovery:Number = curTime - Global.player.getFeatureLastShown(FUEL_DISCOVERY_OWN_FARM_FEATURE_NAME);
         var fuelDiscoveryTimeInterval:Number = Global.farmGameSettingsManager.getNumber("fuelDiscoveryOwnFarmInterval",86400);
         var isTimeEligible:Boolean = timeSinceLastFuelDiscovery > fuelDiscoveryTimeInterval;
         var isLevelEligible:Boolean = Global.player.level >= Global.farmGameSettingsManager.getInt("fuelFeatureMinLevel",12);
         return isTimeEligible && isLevelEligible;
      }
      
      override public function getTransactionData() : Object
      {
         var result:Object = new Object();
         result.method = TWorldState.METHOD_PERFORM_ACTION;
         result.action = ACTION_PLOW;
         result.type = new Array();
         var terrainCodes:Array = TerrainUtil.getTerrainCodesInArea(this.m_tileX,this.m_tileY,this.m_tileX + m_object.getSize().x,this.m_tileY + m_object.getSize().y);
         result.type.push(terrainCodes);
         return result;
      }
   }
}


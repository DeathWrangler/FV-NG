package Transactions.NeighborActions
{
   import Classes.ImageLoader;
   import Classes.Plot;
   import Classes.ZItem.FarmItem;
   import Classes.feed.OilBarronFeed;
   import Classes.util.ZLocUtils;
   import Display.GenericIconPopup;
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Events.GenericPopupEvent;
   import Transactions.TCancelFriendReward;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   
   public class TFertilizeNeighbor extends TBaseNeighborAction
   {
      
      public static const ENERGY_PER_FIFTHTANK:int = 30;
      
      protected var m_plot:Plot;
      
      protected var m_fert:int = 0;
      
      private var m_itemFoundName:String;
      
      private var m_itemFoundRewardUrl:String;
      
      private var m_itemFoundFeedBundle:String;
      
      private var m_fuel:int;
      
      private var m_fuelFeed:OilBarronFeed;
      
      private var m_fuelLoader:ImageLoader;
      
      public function TFertilizeNeighbor(plot:Plot)
      {
         m_actionType = "fert";
         this.m_plot = plot;
         super(plot);
      }
      
      override protected function onComplete(result:Object) : void
      {
         var iconUrl:String = null;
         var message:String = null;
         var dialog:GenericIconPopup = null;
         super.onComplete(result);
         if(result.fuelDiscovery)
         {
            this.m_fuel = result.fuelDiscovery;
            if(Boolean(result.fuelRewardLink) && !Global.worldManager.isVisitingCommunityNeighbor())
            {
               this.m_fuelFeed = new OilBarronFeed(Global.worldManager.getVisiting(),result.fuelRewardLink);
               this.m_fuelLoader = ImageLoader.getInstance(Global.getAssetURL(Plot.FERTILIZE_FUELSUCCESS_URL));
               this.m_fuelLoader.getContent(this.onFuelLoad);
            }
         }
         var itemFound:FarmItem = null;
         if(null != result.itemFoundName && "" != result.itemFoundName)
         {
            this.m_itemFoundName = result.itemFoundName;
            itemFound = Global.farmGameSettingsManager.getFarmItemByName(this.m_itemFoundName);
            Global.player.addGift(this.m_itemFoundName);
         }
         else if(null != result.itemShareName)
         {
            this.m_itemFoundName = result.itemShareName;
            itemFound = Global.farmGameSettingsManager.getFarmItemByName(this.m_itemFoundName);
         }
         if(Boolean(itemFound) && Boolean(result.itemFoundDialogText))
         {
            iconUrl = Global.farmGameSettingsManager.getImageByName(this.m_itemFoundName,"icon");
            message = ZLocUtils.t("Dialogs",result.itemFoundDialogText,{"item":itemFound.friendlyName});
            dialog = null;
            if(result.itemFoundRewardUrl != "" && result.itemFoundFeedBundle != "")
            {
               this.m_itemFoundRewardUrl = result.itemFoundRewardUrl;
               this.m_itemFoundFeedBundle = result.itemFoundFeedBundle;
               dialog = new GenericIconPopup(message,GenericPopup.TYPE_SHARECANCEL,this.onAcceptShareItemFeed,iconUrl);
               dialog.setTrackerKey("fertilizer-crowdsource_self");
            }
            else if(result.itemFoundName != "")
            {
               dialog = new GenericIconPopup(message,GenericPopup.TYPE_OK,null,iconUrl);
            }
            if(dialog)
            {
               UI.displayPopup(dialog);
            }
         }
      }
      
      private function onAcceptShareItemFeed(event:GenericPopupEvent) : void
      {
         var itemFound:FarmItem = null;
         var friendName:String = null;
         var iconUrl:String = null;
         var params:Object = null;
         if(event.button == GenericPopup.ACCEPT)
         {
            itemFound = Global.farmGameSettingsManager.getFarmItemByName(this.m_itemFoundName);
            if(itemFound)
            {
               friendName = Global.worldManager.getVisitName(true);
               iconUrl = Global.farmGameSettingsManager.getImageByName(this.m_itemFoundName,"icon");
               params = new Object();
               params.images = [{
                  "src":iconUrl,
                  "href":"{SN_APP_URL}" + this.m_itemFoundRewardUrl
               }];
               params.reward_link = this.m_itemFoundRewardUrl;
               params.friend = friendName;
               GlobalEngine.socialNetwork.publishFeedStory(this.m_itemFoundFeedBundle,params,[],false);
            }
         }
         else
         {
            TransactionManager.addTransaction(new TCancelFriendReward([this.m_itemFoundRewardUrl]));
         }
      }
      
      private function onFuelLoad(dispObj:DisplayObject, info:Object = null) : void
      {
         var addedEnergy:Number = NaN;
         var plotDisplayObjectSprite:Sprite = this.m_plot.getDisplayObject() as Sprite;
         plotDisplayObjectSprite.alpha = 1;
         plotDisplayObjectSprite.addChildAt(dispObj,plotDisplayObjectSprite.numChildren - 1);
         (dispObj as MovieClip).addEventListener(Event.ENTER_FRAME,this.fuelEffectEnterFrame);
         (dispObj as MovieClip).gotoAndPlay(1);
         if(this.m_fuel > 0)
         {
            addedEnergy = this.m_fuel * TFertilizeNeighbor.ENERGY_PER_FIFTHTANK;
            Global.player.energy += addedEnergy;
            Global.hud.flashFuelBar();
            this.m_fuelFeed.startFeedFlow();
         }
      }
      
      private function fuelEffectEnterFrame(event:Event) : void
      {
         var effect:MovieClip = event.target as MovieClip;
         if(effect.currentFrame >= effect.totalFrames)
         {
            effect.removeEventListener(Event.ENTER_FRAME,this.fuelEffectEnterFrame);
            if(effect.parent)
            {
               effect.parent.removeChild(effect);
            }
         }
      }
   }
}


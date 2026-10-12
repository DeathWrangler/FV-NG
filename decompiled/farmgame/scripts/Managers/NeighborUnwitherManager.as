package Managers
{
   import Classes.Plot;
   import Classes.WorldObjectTypes;
   import Classes.ZItem.FarmItem;
   import Classes.consumables.CUnwither;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.GenericIconPopup;
   import Display.GenericPopup;
   import Display.NeighborUnwitherDialog;
   import Display.UI;
   import Engine.Classes.WorldObject;
   import Events.GenericPopupEvent;
   
   public class NeighborUnwitherManager
   {
      
      private const DEFAULT_DAYS_TO_DEAD:int = 28;
      
      public const UNWITHER_CONSUMABLE_ITEM_CODE:String = "A3";
      
      private var m_visitedUserId:String = "0";
      
      private var m_visitedUserName:String;
      
      public function NeighborUnwitherManager()
      {
         super();
      }
      
      private function hasWitheredPlots() : Boolean
      {
         var plots:Array = null;
         var i:int = 0;
         var worldObjectPlot:WorldObject = null;
         var plot:Plot = null;
         var response:Boolean = false;
         if(Global.world != null)
         {
            plots = Global.world.getObjectsByType(WorldObjectTypes.PLOT);
            for(i = 0; i < plots.length; i++)
            {
               worldObjectPlot = plots[i] as WorldObject;
               plot = Plot(worldObjectPlot);
               if(plot.isWithered())
               {
                  response = true;
                  break;
               }
            }
         }
         return response;
      }
      
      private function offerToPublishYourAction() : void
      {
         var msg:String = ZLocUtils.t("Dialogs","Unwither_prompt_share",{"user":ZLocUtils.tn(this.m_visitedUserName)});
         var genPop:GenericPopup = new GenericPopup(msg,GenericPopup.TYPE_YESNO,this.onPublishNeighbourlyUnwitherAct,GenericPopup.GENERIC_ASSET);
         genPop.setTrackerKey("unwither-share_neighbor_unwither");
         UI.displayPopup(genPop,false,"",true);
      }
      
      private function onPublishNeighbourlyUnwitherAct(event:GenericPopupEvent) : void
      {
         var unwitherConsumable:FarmItem = null;
         var iconUrl:String = null;
         var images:Array = null;
         if(event.button == GenericPopup.ACCEPT)
         {
            unwitherConsumable = Global.farmGameSettingsManager.getFarmItemByCode(this.UNWITHER_CONSUMABLE_ITEM_CODE);
            iconUrl = unwitherConsumable.icon;
            images = [{
               "src":iconUrl,
               "href":"{SN_APP_URL}"
            }];
            GlobalEngine.socialNetwork.publishFeedStory("ShareNeighborUnwither",{"images":images},[this.m_visitedUserId],false);
         }
      }
      
      public function offerFullFarmUnwither(targetUserData:Object, targetUserName:String) : void
      {
         var daysToDead:int = 0;
         var secondsInADay:int = 0;
         var currentTime:int = 0;
         var daysSinceTargetPlayed:int = 0;
         var unwitherConsumable:FarmItem = null;
         var iconUrl:String = null;
         var unwitherFreeMessage:String = null;
         var unwitherFreePopUp:GenericIconPopup = null;
         this.m_visitedUserId = targetUserData.id;
         this.m_visitedUserName = targetUserName;
         var unwitherDialogShown:Boolean = false;
         if(this.hasWitheredPlots())
         {
            daysToDead = Global.farmGameSettingsManager.getInt("unwitherNeighborFarmForFreeIfInactiveDays",this.DEFAULT_DAYS_TO_DEAD);
            secondsInADay = int(FarmGameUtil.NUM_SECS_IN_DAY);
            currentTime = GlobalEngine.serverTime / 1000;
            daysSinceTargetPlayed = (currentTime - targetUserData.lastWorldAction) / secondsInADay;
            unwitherConsumable = Global.farmGameSettingsManager.getFarmItemByCode(this.UNWITHER_CONSUMABLE_ITEM_CODE);
            iconUrl = unwitherConsumable.icon;
            if(daysSinceTargetPlayed >= daysToDead)
            {
               unwitherFreeMessage = ZLocUtils.t("Dialogs","Unwither_prompt_free",{"user":ZLocUtils.tn(this.m_visitedUserName)});
               unwitherFreePopUp = new GenericIconPopup(unwitherFreeMessage,GenericPopup.TYPE_YESNO,this.onFullFarmUnwitherForFree,iconUrl);
               UI.displayPopup(unwitherFreePopUp,false,"",true);
            }
            else
            {
               unwitherDialogShown = NeighborUnwitherDialog.conditionallyShowUnwitherDialog();
            }
         }
      }
      
      private function onFullFarmUnwither(event:GenericPopupEvent) : void
      {
         var unwitherConsumable:CUnwither = null;
         if(event.button == GenericPopup.ACCEPT)
         {
            FarmStatsManager.count("friend_unwither","active_neighbor","accept_unwither");
            this.offerToPublishYourAction();
            unwitherConsumable = new CUnwither("consume_unwither");
            unwitherConsumable.consume(true,false,this.m_visitedUserId,false);
         }
         else
         {
            FarmStatsManager.count("friend_unwither","active_neighbor","decline_unwither");
         }
      }
      
      private function onFullFarmUnwitherForFree(event:GenericPopupEvent) : void
      {
         var unwitherConsumable:CUnwither = null;
         if(event.button == GenericPopup.ACCEPT)
         {
            FarmStatsManager.count("friend_unwither","inactive_neighbor","accept_unwither");
            this.offerToPublishYourAction();
            unwitherConsumable = new CUnwither("consume_unwither");
            unwitherConsumable.consume(true,false,this.m_visitedUserId.toString(),true);
         }
         else
         {
            FarmStatsManager.count("friend_unwither","inactive_neighbor","decline_unwither");
         }
      }
   }
}


package GameMode
{
   import Classes.Building;
   import Classes.EmbeddedArt;
   import Classes.MapResource;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Classes.WorldObject;
   import Engine.Constants;
   import Engine.Managers.TransactionManager;
   import Events.GenericPopupEvent;
   import Managers.FarmStatsManager;
   import Transactions.TUseTargetedConsumable;
   import flash.events.MouseEvent;
   import flash.filters.GlowFilter;
   
   public class GMSetOverlayGraphic extends GMSetAltGraphic
   {
      
      protected const TOILETPAPER_SETTINGS:String = "tp";
      
      protected var m_overlayName:String;
      
      public function GMSetOverlayGraphic(overlayName:String)
      {
         super(overlayName);
         this.m_overlayName = overlayName;
         m_cursorImage = EmbeddedArt.hud_resource_tp;
      }
      
      override protected function selectObject(object:WorldObject, event:MouseEvent = null) : void
      {
         var farmObj:MapResource = null;
         farmObj = object as MapResource;
         if(object != m_highlightedObject)
         {
            deselectObject();
            m_highlightedObject = object;
            if(object)
            {
               farmObj.getDisplayObject().filters = [new GlowFilter(Constants.COLOR_HIGHLIGHT,1,8,8,20)];
               farmObj.setToolTip(ZLocUtils.t("FarmGame","ClickToTP"));
            }
            updateCursor();
         }
      }
      
      override protected function isObjectSelectable(object:WorldObject) : Boolean
      {
         var result:Boolean = false;
         var mapObject:Building = object as Building;
         if(mapObject != null)
         {
            result = mapObject.isValidOverlayTarget("tp");
         }
         return result;
      }
      
      override protected function handleClick(event:MouseEvent) : void
      {
         var building:Building = null;
         var visitingID:String = null;
         var uid:String = null;
         var target:Number = NaN;
         var visiting:String = null;
         var userName:String = null;
         var userGender:String = null;
         var message:String = null;
         if(m_highlightedObject)
         {
            building = m_highlightedObject as Building;
            if(Boolean(building) && Global.player.hasGiftItem("TC"))
            {
               if(this.isObjectSelectable(building))
               {
                  visitingID = Global.worldManager.getVisiting();
                  if(Boolean(visitingID) && visitingID.length > 1)
                  {
                     uid = visitingID;
                     target = m_highlightedObject.getId();
                     building.applyOverlay(this.m_overlayName);
                     TransactionManager.addTransaction(new TUseTargetedConsumable("consume_toiletpaper",target,true,uid,false),true);
                     visiting = Global.worldManager.getVisiting();
                     userName = Global.worldManager.getVisitName(true);
                     userGender = Global.worldManager.getVisitGender();
                     message = ZLocUtils.t("Dialogs","ToiletPaperFeedPrompt",{"user":ZLocUtils.tn(userName,ZLocUtils.tg(userGender))});
                     UI.displayMessage(message,GenericPopup.TYPE_SHARECANCEL,this.onShareAntics);
                  }
                  Global.world.removeGameMode(this);
                  Global.world.setDefaultGameMode();
               }
            }
         }
      }
      
      protected function onShareAntics(event:GenericPopupEvent) : void
      {
         var url:String = null;
         var params:Object = null;
         if(event.button == GenericPopup.ACCEPT)
         {
            url = "assets/newsfeed/barn_tp_icon.png";
            params = {"images":[{
               "src":Global.getAssetURL(url),
               "href":Config.SN_APP_URL
            }]};
            GlobalEngine.socialNetwork.publishFeedStory("feed_aprilfools_i_tped",params,[Global.worldManager.getVisiting()],false);
            FarmStatsManager.count("ToiletPaper","Used","click_share");
         }
         else
         {
            FarmStatsManager.count("ToiletPaper","Used","click_cancel");
         }
      }
   }
}


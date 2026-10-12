package GameMode
{
   import Classes.FeatureBuilding;
   import Classes.MapResource;
   import Classes.UGC.IUGCMapResource;
   import Classes.ZItem.IUGCItem;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Transactions.TUGCItemPlace;
   import flash.events.MouseEvent;
   
   public class GMUGCItemPlace extends GMObjectMove
   {
      
      private var m_ugcItem:IUGCItem;
      
      private var m_ugcUuid:String;
      
      public function GMUGCItemPlace(ugcItem:IUGCItem, ugcUuid:Object, buildingId:Number = 0, isGift:Boolean = false, repopGift:Boolean = true)
      {
         this.m_ugcItem = ugcItem;
         this.m_ugcUuid = ugcUuid as String;
         m_cid = buildingId;
         if(isGift)
         {
            m_storedOrigin = Global.world.GIFTBOX_ID;
         }
         else
         {
            m_storedOrigin = buildingId;
         }
         super(null,null,isGift,repopGift);
      }
      
      override public function onMouseMove(event:MouseEvent) : Boolean
      {
         var UGCItemClass:Class = null;
         if(m_selectedObject == null)
         {
            m_highlightedPoint = getMouseTilePos();
            UGCItemClass = this.m_ugcItem.farmItem.getMapResourceClass();
            m_selectedObject = new UGCItemClass(this.m_ugcItem.farmItem.name,this.m_ugcUuid) as MapResource;
            m_selectedObject.setOuter(Global.world);
            m_selectedObject.setPosition(m_highlightedPoint.x,m_highlightedPoint.y);
         }
         return super.onMouseMove(event);
      }
      
      override public function onMouseUp(event:MouseEvent) : Boolean
      {
         var featureBuilding:FeatureBuilding = Global.world.getObjectById(m_cid) as FeatureBuilding;
         if(featureBuilding != null)
         {
            featureBuilding.lastMetaHashRemoved = this.m_ugcItem.farmItem.code + ":" + this.m_ugcUuid;
         }
         var result:Boolean = super.onMouseUp(event);
         if(m_objectPlacedSuccess)
         {
            if(Global.world.checkNumObjectLimit())
            {
               if(!m_selectedObject.isToolGenerated)
               {
                  TransactionManager.addTransaction(new TUGCItemPlace(m_selectedObject as IUGCMapResource,this.m_ugcUuid,m_isGift,m_cid));
               }
               Global.world.setDefaultGameMode();
            }
            else
            {
               UI.displayMessage(ZLocUtils.t("Dialogs","Maxed_Objects_Full"));
               Global.world.addGameMode(this);
            }
         }
         return result;
      }
   }
}


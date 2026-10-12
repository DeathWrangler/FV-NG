package GameMode
{
   import Classes.FarmGameObject;
   import Classes.MystreeReskinSapling;
   import Managers.MystreeReskinManager;
   import Transactions.TMystreeReskinPlant;
   import flash.events.MouseEvent;
   
   public class GMPlantMystreeReskin extends GMObjectMove
   {
      
      private var m_itemType:String;
      
      private var m_item:MystreeReskinSapling;
      
      private var m_plotId:String;
      
      private var m_featureName:String;
      
      public function GMPlantMystreeReskin(treeType:String, plotId:String, featureName:String, isGift:Boolean = false, buildingId:Number = 0, shouldReopenGift:Boolean = true, currency:String = "")
      {
         this.m_itemType = treeType;
         m_isGift = isGift;
         m_cid = buildingId;
         m_storedOrigin = buildingId;
         this.m_plotId = plotId;
         this.m_featureName = featureName;
         super(null,null,isGift,shouldReopenGift,false,currency);
         if(Global.flashHotParams["MP_SELECTED_INITIALIZED_ON_CONSTRUCTOR"])
         {
            this.createSelectedObject();
         }
      }
      
      override public function onMouseMove(event:MouseEvent) : Boolean
      {
         if(!Global.flashHotParams["MP_SELECTED_INITIALIZED_ON_CONSTRUCTOR"])
         {
            this.createSelectedObject();
         }
         return super.onMouseMove(event);
      }
      
      protected function createSelectedObject() : void
      {
         if(!m_selectedObject)
         {
            m_highlightedPoint = getMouseTilePos();
            this.m_item = new MystreeReskinSapling(this.m_itemType,this.m_plotId,this.m_featureName);
            this.m_item.setOuter(Global.world);
            this.m_item.setPosition(m_highlightedPoint.x,m_highlightedPoint.y);
            m_selectedObject = this.m_item as FarmGameObject;
         }
      }
      
      override public function onMouseUp(event:MouseEvent) : Boolean
      {
         super.onMouseUp(event);
         if(m_objectPlacedSuccess)
         {
            this.m_item.addTransaction(new TMystreeReskinPlant(this.m_item,this.m_featureName,m_isGift,0,0,null,m_storedOrigin,this.m_currency,this.m_item.sendTransformTransaction));
            this.m_item.showTransformAnimation();
            MystreeReskinManager.getInstance(this.m_featureName).onMystreePlaced(this.m_plotId);
         }
         return true;
      }
   }
}


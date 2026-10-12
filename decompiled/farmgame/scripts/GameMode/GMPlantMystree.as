package GameMode
{
   import Classes.FarmGameObject;
   import Classes.MystreeSapling;
   import Managers.MystreeNurseryManager;
   import Transactions.TMystreePlant;
   import flash.events.MouseEvent;
   
   public class GMPlantMystree extends GMObjectMove
   {
      
      private var m_treeType:String;
      
      private var m_tree:MystreeSapling;
      
      private var m_plotId:String;
      
      public function GMPlantMystree(treeType:String, plotId:String, isGift:Boolean = false, buildingId:Number = 0, shouldReopenGift:Boolean = true, currency:String = "")
      {
         this.m_treeType = treeType;
         m_isGift = isGift;
         m_cid = buildingId;
         m_storedOrigin = buildingId;
         this.m_plotId = plotId;
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
            this.m_tree = new MystreeSapling(this.m_treeType,this.m_plotId);
            this.m_tree.setOuter(Global.world);
            this.m_tree.setPosition(m_highlightedPoint.x,m_highlightedPoint.y);
            m_selectedObject = this.m_tree as FarmGameObject;
         }
      }
      
      override public function onMouseUp(event:MouseEvent) : Boolean
      {
         super.onMouseUp(event);
         if(m_objectPlacedSuccess)
         {
            this.m_tree.addTransaction(new TMystreePlant(this.m_tree,m_isGift,0,0,null,m_storedOrigin,this.m_currency,this.m_tree.sendTransformTransaction));
            this.m_tree.showTransformAnimation();
            MystreeNurseryManager.getInstance().onMystreePlaced(this.m_plotId);
         }
         return true;
      }
   }
}


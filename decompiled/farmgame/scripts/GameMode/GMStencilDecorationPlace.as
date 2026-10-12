package GameMode
{
   import Classes.MapResource;
   import Managers.StencilManager;
   
   public class GMStencilDecorationPlace extends GMDecorationPlace
   {
      
      public function GMStencilDecorationPlace(decorationType:String, isGift:Boolean = false, buildingId:Number = 0, shouldReOpenGift:Boolean = true, currency:String = "")
      {
         super(decorationType,isGift,buildingId,shouldReOpenGift,currency);
      }
      
      override public function bypassBuy() : Boolean
      {
         var itemName:String = (m_selectedObject as MapResource).getItemName();
         return StencilManager.instance().ownsStencil(itemName);
      }
   }
}


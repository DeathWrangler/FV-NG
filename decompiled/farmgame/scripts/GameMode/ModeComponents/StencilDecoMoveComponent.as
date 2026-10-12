package GameMode.ModeComponents
{
   import Classes.FarmGameObject;
   import Classes.ItemImage;
   import Classes.MapResource;
   import Classes.StencilDecoration;
   import Classes.ZItem.DecorationItem;
   import GameMode.GMObjectMove;
   import GameMode.GameMode;
   import flash.events.MouseEvent;
   
   public class StencilDecoMoveComponent implements IGameModeComponent
   {
      
      private var m_mapResource:StencilDecoration;
      
      private var m_item:DecorationItem;
      
      private var m_stencilImage:ItemImage = null;
      
      public function StencilDecoMoveComponent(selectedObject:MapResource)
      {
         super();
         this.m_mapResource = selectedObject as StencilDecoration;
         this.m_item = this.m_mapResource.getItem() as DecorationItem;
      }
      
      public static function canApply(mode:GameMode, selectedObject:FarmGameObject) : Boolean
      {
         var result:Boolean = false;
         if(mode is GMObjectMove && selectedObject != null && selectedObject is StencilDecoration)
         {
            result = true;
         }
         return result;
      }
      
      public function enableMode() : void
      {
      }
      
      public function disableMode() : void
      {
         this.m_mapResource.hideStencilEffect();
      }
      
      public function onMouseMove(event:MouseEvent) : Boolean
      {
         if(!this.m_stencilImage)
         {
            this.m_stencilImage = this.m_item.getCachedImage(this.m_mapResource.getCurrentStencilState());
         }
         else
         {
            this.m_mapResource.showStencilEffect(this.m_stencilImage);
         }
         return true;
      }
      
      public function handleObjectDrop(event:MouseEvent) : void
      {
         this.m_mapResource.showStencil();
      }
   }
}


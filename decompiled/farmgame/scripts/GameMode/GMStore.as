package GameMode
{
   import Classes.EmbeddedArt;
   import Classes.MapResource;
   import Engine.Classes.WorldObject;
   import flash.events.MouseEvent;
   
   public class GMStore extends GMDefault
   {
      
      public function GMStore()
      {
         super();
         m_cursorImage = EmbeddedArt.cursor_store_item;
      }
      
      override protected function selectObject(object:WorldObject, event:MouseEvent = null) : void
      {
         var mapResource:MapResource = null;
         var canAdd:Boolean = false;
         if(object != m_highlightedObject)
         {
            deselectObject();
            mapResource = object as MapResource;
            if(mapResource != null)
            {
               canAdd = mapResource.canAddToInventory();
               if(canAdd)
               {
                  m_highlightedObject = object;
               }
               if(m_highlightedObject)
               {
                  m_highlightedObject.onMouseOver(event);
               }
            }
         }
      }
      
      override protected function handleClick(event:MouseEvent) : void
      {
         var mapResource:MapResource = null;
         if(m_highlightedObject)
         {
            mapResource = m_highlightedObject as MapResource;
            mapResource.addToInventory();
         }
      }
   }
}


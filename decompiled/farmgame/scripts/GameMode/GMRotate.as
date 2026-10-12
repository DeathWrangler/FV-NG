package GameMode
{
   import Classes.EmbeddedArt;
   import Classes.IRotatable;
   import Engine.Classes.WorldObject;
   import flash.events.MouseEvent;
   
   public class GMRotate extends GMDefault
   {
      
      public function GMRotate()
      {
         super();
         m_cursorImage = EmbeddedArt.cursor_rotate;
      }
      
      override protected function handleClick(event:MouseEvent) : void
      {
         var rotatable:IRotatable = null;
         if(m_highlightedObject)
         {
            rotatable = m_highlightedObject as IRotatable;
            if(rotatable != null && rotatable.canRotate())
            {
               rotatable.rotate(true);
            }
         }
      }
      
      override protected function selectObject(object:WorldObject, event:MouseEvent = null) : void
      {
         var rotatble:IRotatable = null;
         if(object != m_highlightedObject)
         {
            rotatble = object as IRotatable;
            deselectObject();
            if(rotatble != null && rotatble.canRotate())
            {
               m_highlightedObject = object;
            }
            else
            {
               m_highlightedObject = null;
            }
            if(m_highlightedObject)
            {
               m_highlightedObject.onMouseOver(event);
            }
         }
      }
   }
}


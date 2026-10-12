package GameMode
{
   import Classes.Avatar.FarmAvatar;
   import Classes.HarvestableResource;
   import Classes.MapResource;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   
   public class GMMultiResourceHarvest extends GMMultiResourceAction
   {
      
      public function GMMultiResourceHarvest()
      {
         super();
      }
      
      override protected function handleClick(event:MouseEvent) : void
      {
         var selectedResources:Array = null;
         var i:int = 0;
         var resource:HarvestableResource = null;
         var centerX:int = 0;
         var centerY:int = 0;
         var centerPosition:Point = null;
         if(Boolean(Global.player) && Boolean(Global.selectedAvatar) && Boolean(m_highlightedPoint))
         {
            selectedResources = [];
            for(i = 0; i < m_resourceData.length; i++)
            {
               if(m_resourceData[i].valid)
               {
                  resource = m_resourceData[i].object as HarvestableResource;
                  if(resource)
                  {
                     selectedResources.push(resource);
                  }
               }
            }
            if(selectedResources.length)
            {
               centerX = m_highlightedPoint.x + m_actionSize.x / 2 * m_resourceSize.x;
               centerY = m_highlightedPoint.y + m_actionSize.y / 2 * m_resourceSize.y;
               centerPosition = new Point(centerX,centerY);
               this.addAvatarState(Global.selectedAvatar,selectedResources,centerPosition);
               reselectResources();
               updateOverlay();
            }
         }
      }
      
      override protected function isSelectable(resource:MapResource) : Boolean
      {
         var result:Boolean = false;
         if(Boolean(resource) && Boolean(resource is HarvestableResource) && (resource as HarvestableResource).isHarvestable())
         {
            result = true;
         }
         return result;
      }
      
      protected function addAvatarState(avatar:FarmAvatar, resources:Array, centerPos:Point) : void
      {
      }
   }
}


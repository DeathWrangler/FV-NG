package Classes.FeatureComponents
{
   import Classes.FeatureBuilding;
   import Classes.Idle.FarmItemDependentPostInitIdleTask;
   import Classes.Idle.IdleTaskQueue;
   import Engine.Managers.ErrorManager;
   import Engine.Utilities;
   import flash.display.MovieClip;
   import flash.utils.getDefinitionByName;
   
   public class FeaturedRenderDecalFManager extends FeaturedRenderFManager implements IRenderComponent
   {
      
      private var m_objectTypes:Array;
      
      public function FeaturedRenderDecalFManager(owner:FeatureBuilding)
      {
         this.m_objectTypes = [FeaturedRenderFDecalObject];
         super(owner);
         if(!Global.farmGameSettingsManager.itemsXMLParsingComplete)
         {
            IdleTaskQueue.getInstance().addTask(new FarmItemDependentPostInitIdleTask(function():void
            {
               updateBuildingDisplay();
               updateDisplay();
            }));
         }
      }
      
      private function updateBuildingDisplay() : void
      {
         var featuredSlotIndex:String = null;
         var featuredSlot:Object = null;
         var itemName:String = null;
         var objClass:Class = null;
         var renderedObj:FeaturedRenderFDecalObject = null;
         var featuredItems:Object = owner.getFeaturedItems();
         for(featuredSlotIndex in featuredItems)
         {
            featuredSlot = featuredItems[featuredSlotIndex];
            if(featuredSlot != null)
            {
               itemName = Global.farmGameSettingsManager.getFarmItemNameByCode(featuredSlot.itemCode);
               try
               {
                  objClass = getDefinitionByName(m_renderObjectClass) as Class;
                  renderedObj = new objClass(itemName,owner);
               }
               catch(error:Error)
               {
                  ErrorManager.addError("FeaturedRenderDecalFManager cannot instantiate FeaturedRenderFDecalObject:" + itemName);
               }
               m_featuredObjects[featuredSlotIndex] = renderedObj;
            }
         }
      }
      
      override public function setState(state:String, featuredItems:Object = null) : void
      {
         if(featuredItems != null)
         {
            m_featuredObjects = [];
            this.updateBuildingDisplay();
         }
      }
      
      override public function updateTransforms() : void
      {
      }
      
      override public function updateDisplay() : void
      {
         var propIndex:int = 0;
         var propPointName:String = null;
         var propPoint:MovieClip = null;
         var featuredObject:FeaturedRenderFDecalObject = null;
         if(owner.content is MovieClip)
         {
            for(propIndex = 0; propIndex < m_maxItems; propIndex++)
            {
               propPointName = m_propPointPrefix + "PropPoint_" + propIndex;
               if(owner.content.hasOwnProperty(propPointName))
               {
                  propPoint = owner.content[m_propPointPrefix + "PropPoint_" + propIndex];
                  if(propPoint)
                  {
                     Utilities.removeAllChildren(propPoint);
                     if(m_featuredObjects.hasOwnProperty(propIndex))
                     {
                        featuredObject = m_featuredObjects[propIndex];
                        propPoint.addChild(featuredObject);
                     }
                  }
               }
            }
            updateBuildingTextField();
         }
         owner.conditionallyRedraw(true);
      }
      
      override public function updateCulling() : void
      {
      }
      
      override public function render() : void
      {
         if(m_featuredObjects.length == 0 && owner.getFeaturedItems() != null)
         {
            this.updateBuildingDisplay();
         }
      }
   }
}


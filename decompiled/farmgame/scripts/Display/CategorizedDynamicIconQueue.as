package Display
{
   import Classes.Constants.Experiments;
   import flash.events.MouseEvent;
   
   public class CategorizedDynamicIconQueue extends DynamicIconQueue
   {
      
      public static const ICON_TYPE_FEATURE:String = "feature";
      
      public static const ICON_TYPE_STORY:String = "story";
      
      public static const ICON_TYPE_SOCIAL:String = "social";
      
      public static const ICON_TYPE_SIDE_QUEST:String = "sidequests";
      
      public static const ICON_TYPE_NEIGHBOR_VISIT:String = "neighborvisit";
      
      public static const ICON_TYPE_LEADERBOARD:String = "leaderboard";
      
      public static const ICON_TYPE_FACEOFF:String = "faceoff";
      
      public static const ICON_TYPE_MARKETING:String = "marketing";
      
      public static const ICON_TYPE_XPROMO:String = "xpromo";
      
      private static const INEXISTANT_CATEGORY:String = "InexistantCategory";
      
      private static const MIN:String = "DefaultIcons";
      
      private static const MAX:String = "MaxIcons";
      
      private static const PRIORITY:String = "priority";
      
      private static const LOCATION:String = "Location";
      
      private var m_categoriesData:Object = {};
      
      private var m_visibleCategoryAmountHash:Object;
      
      protected var m_invisibleIcons:Vector.<QueuedIcon>;
      
      public function CategorizedDynamicIconQueue(side:int = 0)
      {
         super(null,side);
         m_slideDirection = DynamicIconQueue.SLIDE_DIRECTION_BOTTOM_UP;
         this.m_visibleCategoryAmountHash = new Object();
         this.m_invisibleIcons = new Vector.<QueuedIcon>();
         var categoryDefinitions:XMLList = Global.farmGameSettingsManager.getIconCategoryDefinitions();
         this.initCategoriesFromXml(categoryDefinitions);
      }
      
      private function initCategoriesFromXml(data:XMLList) : void
      {
         var rawCategoryData:XML = null;
         var resultData:Object = {};
         var categoryName:String = null;
         var categoryData:Object = null;
         for each(rawCategoryData in data)
         {
            categoryName = rawCategoryData.@icons.toString();
            categoryData = {};
            categoryData[PRIORITY] = parseInt(rawCategoryData.@priority.toString());
            categoryData[MAX] = parseInt(rawCategoryData.@MaxIcons.toString());
            categoryData[MIN] = parseInt(rawCategoryData.@DefaultIcons.toString());
            categoryData[LOCATION] = rawCategoryData.@Location.toString();
            resultData[categoryName] = categoryData;
         }
         this.setCategories(resultData);
      }
      
      private function setCategories(data:Object) : void
      {
         this.m_categoriesData = data;
      }
      
      private function getMaxIconsForCategory(categoryName:String) : int
      {
         var maxIcons:int = Global.flashHotParams["CAT_ICONS_ALLOW_INEXISTENT_CATEGORY_TEMPRT"] ? m_numVisibleIcons : 0;
         var category:Object = this.m_categoriesData[categoryName];
         if(category != null)
         {
            maxIcons = int(category[MAX]);
         }
         if(categoryName == ICON_TYPE_STORY && Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_QUEST_MANAGER) == Experiments.VARIANT_QUEST_MANAGER_ON && Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_QUEST_MANAGER_HUD) == Experiments.VARIANT_QUEST_MANAGER_HUD_QUEST_ICONS_OFF)
         {
            maxIcons = 0;
         }
         return maxIcons;
      }
      
      private function getCategoryPriority(category:String) : int
      {
         var result:int = int.MAX_VALUE;
         var categoryData:Object = this.m_categoriesData[category];
         if(categoryData != null)
         {
            result = int(categoryData[PRIORITY]);
         }
         return result;
      }
      
      private function addToInvisibleList(icon:QueuedIcon) : void
      {
         var insertIndex:int = 0;
         for(insertIndex = 0; insertIndex < this.m_invisibleIcons.length; insertIndex++)
         {
            if(this.m_invisibleIcons[insertIndex].priority > icon.priority)
            {
               break;
            }
         }
         this.m_invisibleIcons.splice(insertIndex,0,icon);
      }
      
      private function sanatizeIconCategory(categoryName:String) : String
      {
         if(categoryName == null || categoryName == "")
         {
            categoryName = INEXISTANT_CATEGORY;
         }
         return categoryName;
      }
      
      private function spliceAddVisibleIcon(index:int, icon:QueuedIcon) : void
      {
         m_visibleIcons.splice(index,0,icon);
         var categoryName:String = this.sanatizeIconCategory(icon.category);
         if(!this.m_visibleCategoryAmountHash.hasOwnProperty(categoryName))
         {
            this.m_visibleCategoryAmountHash[categoryName] = 0;
         }
         ++this.m_visibleCategoryAmountHash[categoryName];
      }
      
      private function spliceRemoveVisibleIcon(index:int) : void
      {
         var categoryName:String = null;
         var icon:QueuedIcon = m_visibleIcons[index];
         if(icon != null)
         {
            m_visibleIcons.splice(index,1);
            categoryName = this.sanatizeIconCategory(icon.category);
            if(!this.m_visibleCategoryAmountHash.hasOwnProperty(categoryName) || this.m_visibleCategoryAmountHash[categoryName] <= 0)
            {
               throw new Error("CategorizedDynamicIconQueue visible icon category amount is not being tracked properly.");
            }
            --this.m_visibleCategoryAmountHash[categoryName];
            return;
         }
         throw new Error("CategorizedDynamicIconQueue atempting to spliceRemoveVisibleIcon an inexistant icon.");
      }
      
      private function isCategoryFull(categoryName:String) : Boolean
      {
         var result:Boolean = false;
         categoryName = this.sanatizeIconCategory(categoryName);
         var categoryCount:int = 0;
         if(this.m_visibleCategoryAmountHash.hasOwnProperty(categoryName))
         {
            categoryCount = int(this.m_visibleCategoryAmountHash[categoryName]);
         }
         if(categoryCount >= this.getMaxIconsForCategory(categoryName))
         {
            result = true;
         }
         return result;
      }
      
      private function getLeastPriorityCategoryIconIndex(categoryName:String) : int
      {
         var result:int = -1;
         for(var i:* = int(m_visibleIcons.length - 1); i >= 0; i--)
         {
            if(m_visibleIcons[i].category == categoryName)
            {
               result = i;
               break;
            }
         }
         return result;
      }
      
      override public function addIcon(name:String, insertionIndex:int = -1, imageUrl:String = null, extraData:Object = null, save:Boolean = true) : QueuedIcon
      {
         return super.addIcon(name,ADD_BY_PRIORITY,imageUrl,extraData,save);
      }
      
      override public function clearIcons() : void
      {
         super.clearIcons();
         this.m_invisibleIcons = new Vector.<QueuedIcon>();
      }
      
      override public function removeIconByName(name:String) : void
      {
         var icon:QueuedIcon = null;
         var mergedList:Vector.<QueuedIcon> = m_visibleIcons.concat(this.m_invisibleIcons);
         for each(icon in mergedList)
         {
            if(icon.iconName == name)
            {
               this.removeIconAndSurfaceNewIcon(icon);
               break;
            }
         }
      }
      
      override public function removeIconByCode(code:String) : void
      {
         var icon:QueuedIcon = null;
         var mergedList:Vector.<QueuedIcon> = m_visibleIcons.concat(this.m_invisibleIcons);
         for each(icon in mergedList)
         {
            if(icon.code == code)
            {
               this.removeIconAndSurfaceNewIcon(icon);
               break;
            }
         }
      }
      
      override protected function removeIconAndSurfaceNewIcon(icon:QueuedIcon) : void
      {
         var i:int = 0;
         var newIcon:QueuedIcon = null;
         var removedIndex:int = m_visibleIcons.indexOf(icon);
         var surfacedNew:Boolean = false;
         if(removedIndex >= 0 && removedIndex < m_visibleIcons.length)
         {
            this.removeIconVisibility(icon);
            this.spliceRemoveVisibleIcon(removedIndex);
            if(icon.persists)
            {
               saveIcons();
            }
            for(i = 0; i < this.m_invisibleIcons.length; i++)
            {
               newIcon = this.m_invisibleIcons[i];
               if(!this.isCategoryFull(newIcon.category))
               {
                  this.m_invisibleIcons.splice(i,1);
                  this.handleIcon(this.getIndex(newIcon),newIcon);
                  surfacedNew = true;
                  break;
               }
            }
         }
         else
         {
            removedIndex = this.m_invisibleIcons.indexOf(icon);
            if(removedIndex >= 0 && removedIndex < this.m_invisibleIcons.length)
            {
               this.m_invisibleIcons.splice(removedIndex,1);
            }
         }
         if(!surfacedNew)
         {
            this.repositionAllIcons();
         }
      }
      
      private function repositionAllIcons() : void
      {
         for(var j:int = 0; j < m_visibleIcons.length; j++)
         {
            m_visibleIcons[j].tweenToY(calculateIconYPosition(j));
         }
      }
      
      override protected function handleIcon(index:int, icon:QueuedIcon) : void
      {
         var visibleIconToRemove:int = 0;
         var toRemoveIcon:QueuedIcon = null;
         var categoryFull:Boolean = this.isCategoryFull(icon.category);
         if(index < m_numVisibleIcons)
         {
            visibleIconToRemove = -1;
            if(categoryFull)
            {
               visibleIconToRemove = this.getLeastPriorityCategoryIconIndex(icon.category);
            }
            else if(m_visibleIcons.length == m_numVisibleIcons)
            {
               visibleIconToRemove = m_visibleIcons.length - 1;
            }
            if(visibleIconToRemove >= 0)
            {
               toRemoveIcon = m_visibleIcons[visibleIconToRemove];
               this.spliceRemoveVisibleIcon(visibleIconToRemove);
               this.removeIconVisibility(toRemoveIcon);
               this.addToInvisibleList(toRemoveIcon);
            }
            this.spliceAddVisibleIcon(index,icon);
            addVisibleIcon(index,icon);
            this.repositionAllIcons();
         }
         else
         {
            this.addToInvisibleList(icon);
         }
      }
      
      protected function removeIconVisibility(icon:QueuedIcon) : void
      {
         icon.removeEventListener(MouseEvent.CLICK,onButtonClick);
         icon.tweenOut();
      }
      
      override protected function getIndex(icon:QueuedIcon) : int
      {
         var leastPriorityCategoryIconIndex:int = 0;
         var i:int = 0;
         var result:int = int(m_visibleIcons.length);
         var categoryAvailable:Boolean = true;
         var categoryFull:Boolean = this.isCategoryFull(icon.category);
         if(categoryFull)
         {
            leastPriorityCategoryIconIndex = this.getLeastPriorityCategoryIconIndex(icon.category);
            if(leastPriorityCategoryIconIndex >= 0 && leastPriorityCategoryIconIndex < m_visibleIcons.length)
            {
               categoryAvailable = m_visibleIcons[leastPriorityCategoryIconIndex].priority > icon.priority;
            }
            else
            {
               categoryAvailable = false;
            }
         }
         if(categoryAvailable)
         {
            for(i = 0; i < m_visibleIcons.length; i++)
            {
               if(m_visibleIcons[i].priority > icon.priority || m_visibleIcons[i].priority == icon.priority && this.getCategoryPriority(m_visibleIcons[i].category) > this.getCategoryPriority(icon.category))
               {
                  result = i;
                  break;
               }
            }
         }
         else
         {
            result = m_numVisibleIcons;
         }
         return result;
      }
   }
}


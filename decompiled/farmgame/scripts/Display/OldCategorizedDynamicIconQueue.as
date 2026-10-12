package Display
{
   import Classes.Constants.Experiments;
   import flash.events.MouseEvent;
   
   public class OldCategorizedDynamicIconQueue extends DynamicIconQueue
   {
      
      public static const ICON_TYPE_STORY:String = "story";
      
      public static const ICON_TYPE_SOCIAL:String = "social";
      
      public static const ICON_TYPE_SIDE_QUEST:String = "sidequests";
      
      public static const ICON_TYPE_NEIGHBOR_VISIT:String = "neighborvisit";
      
      public static const ICON_TYPE_LEADERBOARD:String = "leaderboard";
      
      public static const ICON_TYPE_FACEOFF:String = "faceoff";
      
      public static const ICON_TYPE_MARKETING:String = "marketing";
      
      public static const ICON_TYPE_XPROMO:String = "xpromo";
      
      private static const MIN:String = "DefaultIcons";
      
      private static const MAX:String = "MaxIcons";
      
      private static const PRIORITY:String = "priority";
      
      private static const LOCATION:String = "Location";
      
      private static const INVALID_VIEW_INDEX:int = -1;
      
      private var m_categoriesData:Object;
      
      private var m_categories:Object;
      
      public function OldCategorizedDynamicIconQueue(iconCodes:Array = null, side:int = 0)
      {
         var categoryName:String = null;
         this.m_categoriesData = {};
         this.m_categories = {};
         super(iconCodes,side);
         m_slideDirection = DynamicIconQueue.SLIDE_DIRECTION_BOTTOM_UP;
         var categoryDefinitions:XMLList = Global.farmGameSettingsManager.getIconCategoryDefinitions();
         this.initCategoryData(categoryDefinitions,"XML");
         for(categoryName in this.m_categoriesData)
         {
            this.m_categories[categoryName] = new Vector.<QueuedIcon>();
         }
      }
      
      public function initCategoryData(data:Object, type:String = null) : void
      {
         if(type != null)
         {
            switch(type)
            {
               case "XML":
                  this.initCategoriesFromXml(data as XMLList);
                  break;
               default:
                  this.initFromObject(data);
            }
         }
         else
         {
            this.initFromObject(data);
         }
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
      
      private function initFromObject(categoryData:Object) : void
      {
         this.setCategories(categoryData);
      }
      
      private function setCategories(data:Object) : void
      {
         this.m_categoriesData = data;
      }
      
      private function getMaxIconsForCategory(categoryName:String) : int
      {
         var maxIcons:int = 0;
         var category:Object = this.m_categoriesData[categoryName];
         if(category != null)
         {
            maxIcons = int(category[MAX]);
         }
         return maxIcons;
      }
      
      public function get minVisibleHudIcons() : int
      {
         return 0;
      }
      
      protected function removeIconFromBucket(icon:QueuedIcon) : Boolean
      {
         var iconIndex:int = 0;
         var isSuccessfulRemove:Boolean = false;
         var bucket:Vector.<QueuedIcon> = this.getIconCategoryBucket(icon);
         if(bucket != null)
         {
            iconIndex = bucket.indexOf(icon);
            if(iconIndex != INVALID_VIEW_INDEX)
            {
               bucket.splice(iconIndex,1);
               isSuccessfulRemove = true;
            }
         }
         return isSuccessfulRemove;
      }
      
      protected function getBucketByName(categoryName:String) : Vector.<QueuedIcon>
      {
         return this.m_categories[categoryName];
      }
      
      protected function getnextIconFromBucket(categoryName:String) : QueuedIcon
      {
         var nextIcon:QueuedIcon = null;
         var bucket:Vector.<QueuedIcon> = this.getBucketByName(categoryName);
         if(bucket != null)
         {
            nextIcon = bucket.shift();
         }
         return nextIcon;
      }
      
      override protected function getIndex(icon:QueuedIcon) : int
      {
         var bucket:Vector.<QueuedIcon> = null;
         var bucketLen:uint = 0;
         var result:int = 0;
         var iconToAddCategory:String = icon.category;
         var categoryData:Object = this.m_categoriesData[iconToAddCategory];
         if(categoryData != null)
         {
            bucket = this.m_categories[iconToAddCategory];
            bucketLen = bucket.length;
            for(result = 0; result < bucketLen; result++)
            {
               if(bucket[result].priority > icon.priority)
               {
                  break;
               }
            }
         }
         return result;
      }
      
      private function getIconCategoryBucket(icon:QueuedIcon) : Vector.<QueuedIcon>
      {
         var bucket:Vector.<QueuedIcon> = null;
         var iconCategory:String = icon.category;
         var categoryData:Object = this.m_categoriesData[iconCategory];
         if(categoryData != null)
         {
            bucket = this.m_categories[iconCategory];
         }
         return bucket;
      }
      
      private function addIconToVisibleHud(icon:QueuedIcon, index:int) : void
      {
         m_visibleIcons.splice(index,0,icon);
         addVisibleIcon(index,icon);
      }
      
      private function getVisibleIndexRangeOfCategory(categoryName:String) : Object
      {
         var minIndex:int = 0;
         var icon:QueuedIcon = null;
         var result:Object = null;
         var categoryData:Object = this.m_categoriesData[categoryName];
         if(categoryData != null)
         {
            minIndex = 0;
            for each(icon in m_visibleIcons)
            {
               if(this.m_categoriesData[categoryName][PRIORITY] > this.m_categoriesData[icon.category][PRIORITY])
               {
                  minIndex += 1;
               }
            }
            result = {};
            result[MIN] = minIndex;
            result[MAX] = minIndex + categoryData[MIN] - 1;
         }
         return result;
      }
      
      private function addIconToBucketAtIndex(icon:QueuedIcon, bucket:Vector.<QueuedIcon>, iconIndex:int) : void
      {
         bucket.splice(iconIndex,0,icon);
      }
      
      private function getIconViewIndex(icon:QueuedIcon) : int
      {
         var iconCategoryName:String = null;
         var iconRange:Object = null;
         var maxIcons:int = 0;
         var minIndex:int = 0;
         var maxIndex:int = 0;
         var currentIcon:QueuedIcon = null;
         var currentIndex:int = 0;
         var viewIndex:int = INVALID_VIEW_INDEX;
         if(m_visibleIcons.length > 0)
         {
            iconCategoryName = icon.category;
            iconRange = this.getVisibleIndexRangeOfCategory(iconCategoryName);
            if(iconRange != null)
            {
               maxIcons = Math.min(m_visibleIcons.length,m_numVisibleIcons);
               minIndex = Math.min(iconRange[MIN],maxIcons);
               maxIndex = Math.min(iconRange[MAX],maxIcons);
               currentIcon = null;
               currentIndex = 0;
               currentIndex = minIndex;
               while(currentIndex <= maxIndex && currentIndex < m_visibleIcons.length)
               {
                  if(m_visibleIcons[currentIndex].priority >= icon.priority)
                  {
                     break;
                  }
                  currentIndex++;
               }
               viewIndex = currentIndex;
               if(viewIndex > m_numVisibleIcons)
               {
                  viewIndex = INVALID_VIEW_INDEX;
               }
               if(viewIndex > m_visibleIcons.length)
               {
                  viewIndex = m_visibleIcons.length - 1;
               }
            }
         }
         else
         {
            viewIndex = 0;
         }
         return viewIndex;
      }
      
      override protected function handleIcon(index:int, icon:QueuedIcon) : void
      {
         var bucket:Vector.<QueuedIcon> = null;
         var newViewIndex:int = 0;
         var firstIndexPriority:int = 0;
         var lastIndexPrioritySameCategory:int = 0;
         var shouldRemoveIcon:Boolean = false;
         var indexOfIconToRemove:int = 0;
         var currentIndex:int = 0;
         var sameCategoryViewCount:int = 0;
         var visibleIconsLength:int = 0;
         var isQuestManagerBlockingIcon:Boolean = false;
         var currentIcon:QueuedIcon = null;
         var iconToAddCategory:String = icon.category;
         var categoryData:Object = this.m_categoriesData[iconToAddCategory];
         if(categoryData != null)
         {
            bucket = this.m_categories[iconToAddCategory];
            this.addIconToBucketAtIndex(icon,bucket,index);
            newViewIndex = INVALID_VIEW_INDEX;
            firstIndexPriority = INVALID_VIEW_INDEX;
            lastIndexPrioritySameCategory = INVALID_VIEW_INDEX;
            shouldRemoveIcon = false;
            indexOfIconToRemove = INVALID_VIEW_INDEX;
            sameCategoryViewCount = 0;
            visibleIconsLength = int(m_visibleIcons.length);
            for(currentIndex = 0; currentIndex < visibleIconsLength; currentIndex++)
            {
               currentIcon = m_visibleIcons[currentIndex];
               if(currentIcon.category == icon.category)
               {
                  sameCategoryViewCount++;
                  if(currentIcon.priority > icon.priority)
                  {
                     if(lastIndexPrioritySameCategory == INVALID_VIEW_INDEX || currentIcon.priority > m_visibleIcons[lastIndexPrioritySameCategory].priority)
                     {
                        lastIndexPrioritySameCategory = currentIndex;
                     }
                  }
               }
               if(this.m_categoriesData[currentIcon.category][PRIORITY] >= this.m_categoriesData[icon.category][PRIORITY] && currentIcon.priority > icon.priority)
               {
                  if(firstIndexPriority == INVALID_VIEW_INDEX)
                  {
                     firstIndexPriority = currentIndex;
                  }
               }
            }
            if(firstIndexPriority == INVALID_VIEW_INDEX)
            {
               if(visibleIconsLength < m_numVisibleIcons)
               {
                  firstIndexPriority = visibleIconsLength;
               }
            }
            if(sameCategoryViewCount >= this.getMaxIconsForCategory(icon.category))
            {
               if(lastIndexPrioritySameCategory != INVALID_VIEW_INDEX)
               {
                  newViewIndex = firstIndexPriority;
                  shouldRemoveIcon = true;
                  indexOfIconToRemove = lastIndexPrioritySameCategory;
               }
            }
            else if(firstIndexPriority != INVALID_VIEW_INDEX)
            {
               newViewIndex = firstIndexPriority;
               if(visibleIconsLength == m_numVisibleIcons)
               {
                  shouldRemoveIcon = true;
                  indexOfIconToRemove = visibleIconsLength - 1;
               }
            }
            isQuestManagerBlockingIcon = false;
            if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_QUEST_MANAGER) == Experiments.VARIANT_QUEST_MANAGER_ON)
            {
               if(icon.category == ICON_TYPE_STORY && Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_QUEST_MANAGER_HUD) == Experiments.VARIANT_QUEST_MANAGER_HUD_QUEST_ICONS_OFF)
               {
                  isQuestManagerBlockingIcon = false;
               }
            }
            if(newViewIndex != INVALID_VIEW_INDEX && !isQuestManagerBlockingIcon)
            {
               if(shouldRemoveIcon == true)
               {
                  this.removeVisibleIcon(m_visibleIcons[indexOfIconToRemove],true);
                  removeVisibleIconAtIndex(indexOfIconToRemove);
               }
               shiftIconsAtIndex(newViewIndex,true);
               this.addIconToVisibleHud(icon,newViewIndex);
            }
         }
      }
      
      protected function isIconVisible(index:int, categoryName:String, categoryData:Object) : Boolean
      {
         var isIconVisible:Boolean = true;
         if(index >= categoryData[MIN])
         {
            isIconVisible = false;
         }
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_QUEST_MANAGER) == Experiments.VARIANT_QUEST_MANAGER_ON)
         {
            if(categoryName == ICON_TYPE_STORY && Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_QUEST_MANAGER_HUD) == Experiments.VARIANT_QUEST_MANAGER_HUD_QUEST_ICONS_OFF)
            {
               isIconVisible = false;
            }
         }
         return isIconVisible;
      }
      
      protected function canCategoryGrow(categoryName:String) : Boolean
      {
         var bucket:Vector.<QueuedIcon> = null;
         var canGrow:Boolean = false;
         var categoryData:Object = this.m_categoriesData[categoryName];
         if(categoryData != null)
         {
            bucket = this.m_categories[categoryName];
            if(bucket.length <= categoryData[MAX])
            {
               canGrow = true;
            }
         }
         return canGrow;
      }
      
      protected function isIndexOccupiedByCategory(iconIndex:int, categoryName:String) : Boolean
      {
         var icon:QueuedIcon = null;
         var isOccupied:Boolean = false;
         if(iconIndex >= 0 && iconIndex < m_visibleIcons.length)
         {
            icon = m_visibleIcons[iconIndex];
            if(icon.category == categoryName)
            {
               isOccupied = true;
            }
         }
         return isOccupied;
      }
      
      override protected function removeIconAndSurfaceNewIcon(icon:QueuedIcon) : void
      {
         var removedIndex:int = this.removeVisibleIcon(icon);
         if(removedIndex >= 0)
         {
            if(icon.persists)
            {
               saveIcons();
            }
         }
      }
      
      override protected function removeVisibleIcon(icon:QueuedIcon, isReplacing:Boolean = false) : int
      {
         var removedIndex:int = m_visibleIcons.indexOf(icon);
         if(removedIndex >= 0 && removedIndex < m_numVisibleIcons)
         {
            icon.removeEventListener(MouseEvent.CLICK,onButtonClick);
            icon.tweenOut();
            if(isReplacing == false)
            {
               this.removeIconFromBucket(icon);
               shiftIconsAtIndex(removedIndex,false);
               removeVisibleIconAtIndex(removedIndex);
            }
         }
         return removedIndex;
      }
   }
}


package Classes
{
   import DataSources.BaseDataSource;
   import Managers.FarmGameSettingsManager;
   
   public class WishingFountainFeatureBuilding extends FeatureBuilding
   {
      
      public static const BUILT_STATE_PREFIX:String = "built_";
      
      protected var m_buildStates:Array;
      
      public function WishingFountainFeatureBuilding(itemName:String = null)
      {
         super(itemName);
      }
      
      override public function getCurrentSuffix() : int
      {
         return this.getNearestBuildState();
      }
      
      override public function getImageIcon() : String
      {
         return this.assetKey + "_" + this.getNearestBuildState().toString();
      }
      
      protected function initializeBuildStatesArray() : void
      {
         var idx:int = 0;
         var imageName:String = null;
         var itemImagesLength:int = 0;
         var imageArr:Array = null;
         var item:XML = null;
         this.m_buildStates = [];
         var builtPattern:RegExp = new RegExp(BUILT_STATE_PREFIX);
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            imageArr = this.getItem().getArrayFromDataSource("image");
            itemImagesLength = int(imageArr.length);
            for(idx = 0; idx < itemImagesLength; idx++)
            {
               imageName = (imageArr[idx] as BaseDataSource).getString("name");
               if(builtPattern.test(imageName))
               {
                  this.m_buildStates.push(int(imageName.substr(BUILT_STATE_PREFIX.length)));
               }
            }
         }
         else
         {
            item = this.getItem().xml;
            itemImagesLength = item.image.length();
            for(idx = 0; idx < itemImagesLength; idx++)
            {
               imageName = item.image[idx]["@name"].toString();
               if(builtPattern.test(imageName))
               {
                  this.m_buildStates.push(int(imageName.substr(BUILT_STATE_PREFIX.length)));
               }
            }
         }
         this.m_buildStates.sort(Array.NUMERIC);
      }
      
      public function getNearestBuildState() : int
      {
         var index:int = 0;
         var nextIndex:int = 0;
         var result:int = 0;
         var currentLevel:int = m_storageLevel - 1;
         if(this.m_buildStates == null)
         {
            this.initializeBuildStatesArray();
         }
         for(var statesLegth:int = int(this.m_buildStates.length); index < statesLegth; )
         {
            if(index == this.m_buildStates.length - 1)
            {
               result = int(this.m_buildStates[index]);
               break;
            }
            nextIndex = index + 1;
            if(currentLevel >= this.m_buildStates[index] && currentLevel < this.m_buildStates[nextIndex])
            {
               result = int(this.m_buildStates[index]);
               break;
            }
            index++;
         }
         return result;
      }
      
      public function get builtStates() : Array
      {
         return this.m_buildStates;
      }
   }
}


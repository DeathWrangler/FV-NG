package Classes.PphToDo
{
   import Classes.WorldAnalyzer;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   
   public class CloseToCropMasteryAction extends PphAction
   {
      
      private var m_remainingCrops:int = 0;
      
      private var m_currentMasteryLevel:int = 0;
      
      public function CloseToCropMasteryAction()
      {
         super();
      }
      
      override public function createData() : Boolean
      {
         var levelBucket:Object = null;
         var remainingCrops:String = null;
         var orderedArray:Array = null;
         var cropsCount:int = 0;
         var randomIndex:Number = NaN;
         var cropCode:String = null;
         var crop:FarmItem = null;
         var result:Boolean = false;
         var cropsLeftToMasterData:Array = WorldAnalyzer.getCropsLeftToMasterData();
         var plots:Array = WorldAnalyzer.getActionablePlots();
         var threshold:Number = Global.farmGameSettingsManager.getNumber("toDoListActionablePlotThresholdMultiplier",0.5);
         var maxPlot:Number = Math.floor(plots.length * threshold);
         var numberOfLevels:int = int(cropsLeftToMasterData.length);
         for(var level:* = int(numberOfLevels - 1); level >= 0; level--)
         {
            levelBucket = cropsLeftToMasterData[level];
            remainingCrops = "";
            orderedArray = [];
            for(remainingCrops in levelBucket)
            {
               orderedArray.push(Number(remainingCrops));
            }
            orderedArray.sort(Array.NUMERIC);
            cropsCount = 0;
            for each(cropsCount in orderedArray)
            {
               if(cropsCount < maxPlot)
               {
                  randomIndex = Math.floor(levelBucket[cropsCount.toString()].length * Math.random());
                  cropCode = levelBucket[cropsCount.toString()][randomIndex];
                  crop = Global.farmGameSettingsManager.getFarmItemByCode(cropCode);
                  if(crop != null)
                  {
                     m_crop = crop;
                     this.m_remainingCrops = cropsCount;
                     this.m_currentMasteryLevel = level;
                     result = true;
                     break;
                  }
               }
            }
            if(result == true)
            {
               break;
            }
         }
         return result;
      }
      
      override protected function getStatKingdom() : String
      {
         return "crop_mastery_event";
      }
      
      override protected function attachHudIconToolTip() : void
      {
         m_hudIcon.toolTip = ZLocUtils.t("Dialogs","Pph_CloseToMastery",{
            "quantity":this.m_remainingCrops,
            "item":ZLocUtils.tk_pk(m_crop.friendlyName,"",this.m_remainingCrops),
            "ordinal":this.m_currentMasteryLevel + 1
         });
      }
      
      override protected function onIconLoaded(content:DisplayObject) : void
      {
         super.onIconLoaded(content);
         var mc:MovieClip = content as MovieClip;
         if(mc)
         {
            if(mc.emptyBushel_mc != null)
            {
               mc.emptyBushel_mc.visible = false;
            }
         }
      }
   }
}


package Classes.FeatureDataObjects
{
   import Classes.Quest.PrerequisiteUtility;
   import flash.geom.Point;
   
   public class SeedDispenserSeedConfig
   {
      
      public var name:String;
      
      public var prereqs:Array;
      
      public var previewOffset:Point;
      
      public var slotIconUrl:String;
      
      public function SeedDispenserSeedConfig(rawXML:XML)
      {
         super();
         this.name = rawXML.@name.toString();
         if(rawXML.hasOwnProperty("prereqs") && rawXML.prereqs.hasOwnProperty("prereq"))
         {
            this.prereqs = PrerequisiteUtility.parseXmlNodePrereqs(rawXML.prereqs.prereq);
         }
         var previewOffsetX:Number = parseFloat(rawXML.previewOffsetX.toString());
         var previewOffsetY:Number = parseFloat(rawXML.previewOffsetY.toString());
         this.previewOffset = new Point(previewOffsetX,previewOffsetY);
         this.slotIconUrl = rawXML.slotIconUrl.toString();
      }
   }
}


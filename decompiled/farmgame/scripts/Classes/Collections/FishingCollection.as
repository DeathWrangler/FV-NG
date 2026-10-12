package Classes.Collections
{
   import Classes.GameSettingsObject;
   
   public class FishingCollection extends GameSettingsObject
   {
      
      protected var m_collectibleList:Array;
      
      protected var m_featureName:String;
      
      protected var m_collectionName:String;
      
      protected var m_tradeInReward:AnimalBreedingCollectible;
      
      protected var m_tradeInItem:String;
      
      public function FishingCollection(xml:XML)
      {
         var collectibleXML:XML = null;
         var fishingCollectible:FishingCollectible = null;
         super(xml);
         this.m_collectionName = String(xml.@name);
         this.m_collectibleList = new Array();
         var collectibles:XMLList = xml.collectable;
         for each(collectibleXML in collectibles)
         {
            fishingCollectible = new FishingCollectible(collectibleXML,this.m_collectionName);
            this.m_collectibleList.push(fishingCollectible);
         }
      }
      
      public function get collectibles() : Array
      {
         return this.m_collectibleList;
      }
   }
}


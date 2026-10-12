package Classes.Collections
{
   import Classes.GameSettingsObject;
   
   public class AnimalBreedingCollection extends GameSettingsObject
   {
      
      protected var m_collectibleList:Array;
      
      protected var m_featureName:String;
      
      protected var m_tradeInReward:AnimalBreedingCollectible;
      
      protected var m_tradeInItem:String;
      
      protected var m_name:String;
      
      public function AnimalBreedingCollection(xml:XML)
      {
         var collectibleXML:XML = null;
         var tradeInXML:XMLList = null;
         var animalCollectible:AnimalBreedingCollectible = null;
         this.m_collectibleList = new Array();
         super(xml);
         this.m_name = String(xml.@name);
         this.m_featureName = String(xml.@featureName);
         var collectibles:XMLList = xml.collectable;
         for each(collectibleXML in collectibles)
         {
            animalCollectible = new AnimalBreedingCollectible(collectibleXML,this.m_featureName);
            this.m_collectibleList.push(animalCollectible);
         }
         tradeInXML = xml.tradeInReward;
         this.m_tradeInItem = tradeInXML.@gift;
         this.m_tradeInReward = new AnimalBreedingCollectible(tradeInXML[0],this.m_featureName);
      }
      
      public function get featureName() : String
      {
         return this.m_featureName;
      }
      
      public function get collectibles() : Array
      {
         return this.m_collectibleList;
      }
      
      public function get tradeInReward() : AnimalBreedingCollectible
      {
         return this.m_tradeInReward;
      }
      
      public function get tradeInRewardItem() : String
      {
         return this.m_tradeInItem;
      }
   }
}


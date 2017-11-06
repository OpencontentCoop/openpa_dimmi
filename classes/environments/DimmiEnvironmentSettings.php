<?php

use Opencontent\Opendata\Api\Values\Content;
use Opencontent\Opendata\Api\Values\ContentData;
use Opencontent\Opendata\Api\StateRepository;

class DimmiEnvironmentSettings extends DefaultEnvironmentSettings
{
	private static $states = array();

	protected function filterMetaData( Content $content )
    {
        $currentLanguage = $this->getMainLanguage($content);
        $contentObject = $content->getContentObject($currentLanguage);

        $authorArray = array();
        foreach ($contentObject->authorArray() as $author) {
        	$authorObject = $author->contentObject();
        	if ($authorObject instanceof eZContentObject){
	        	$authorArray[] = $authorObject->attribute('name');
	        }
        }

        $moderationState = array(
			'identifier' => null,
			'name' => null,
			'can_moderate' => null,
		);
        $currentVersion = $content->metadata->currentVersion;
        foreach ($content->metadata->stateIdentifiers as $state) {
			if (strpos($state, 'moderation.') !== false){
				if ($state = self::getState($state, $contentObject)){
					$moderationState = $state;
				}
			}
		}

        $content = parent::filterMetaData($content);
        $content->metadata['currentVersion'] = $currentVersion;
		$content->metadata['moderation'] = $moderationState;
		$content->metadata['authorArray'] = array_unique($authorArray);
		
        return $content;
    }

    private function getMainLanguage(Content $content)
    {
        $languages = $content->metadata->languages;
        if (count($languages) > 1){
        	$currentLanguage = eZLocale::currentLocaleCode();
        }else{
        	$currentLanguage = $languages[0];
        }

        return $currentLanguage;
    }

    private function getUserRating($objectId, $attributeId)
    {
    	$cond = array( 
            'user_id' => eZUser::currentUserID(),
            'contentobject_id' => $objectId,
            'contentobject_attribute_id' => $attributeId
        );
        $objects = eZPersistentObject::fetchObjectList( ezsrRatingDataObject::definition(), null, $cond, array('created_at' => 'desc'), array('offset' => 0, 'length' => 1) );

		if (isset($objects[0])){
			return (int)$objects[0]->attribute('rating');
		}
		return 0;
    }

    protected function flatData( Content $content )
    {
    	$currentLanguage = $this->getMainLanguage($content);
    	if (isset($content->data[$currentLanguage]['like_rating']))
    	{
    		$attributeRating = $content->data[$currentLanguage]['like_rating'];
    	}
    	$data = parent::flatData($content)->data->jsonSerialize();    	
    	foreach ($data as $language => $values) {			    		
    		if ($values['links']){    			
    			$data[$language]['links'] = explode(',', $values['links']);    			
    		}
    	}
        $ratingObject = ezsrRatingObject::fetchByObjectId($content->metadata->id, $attributeRating['id']);
    	$data[$language]['_like_rating'] = array(
    		'id' => $attributeRating['id'],
    		'version' => $attributeRating['version'],
    		'user_rating' => $this->getUserRating($content->metadata->id, $attributeRating['id']),
            'rating_count' => $ratingObject ? (int)$ratingObject->attribute('rating_count') : 0,
    	);
		$content->data = new ContentData( $data );
    	return $content;
    }

    private static function getState($identifier, $contentObject)
    {
    	if (!isset(self::$states[$identifier])){
    		$stateRepo = new StateRepository();
    		try{
    			$state = $stateRepo->load($identifier);	
    			$stateObject = $state->getStateObject();    			
                $moderationAcceptState = $stateRepo->load('moderation.accepted');
                $moderationDenyState = $stateRepo->load('moderation.refused');
    			self::$states[$identifier] = array(
					'identifier' => $stateObject->attribute('identifier'),
					'name' => $stateObject->attribute('current_translation')->attribute('name'),
					'can_accept' => in_array($moderationAcceptState['id'], $contentObject->allowedAssignStateIDList()),
                    'can_deny' => in_array($moderationDenyState['id'], $contentObject->allowedAssignStateIDList()),
				);
    		}catch(Exception $e){
    			self::$states[$identifier] = $e->getMessage();
    		}    		
    	}

    	return self::$states[$identifier];
    }
}
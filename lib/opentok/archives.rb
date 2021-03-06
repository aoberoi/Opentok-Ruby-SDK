require "opentok/client"
require "opentok/archive"
require "opentok/archive_list"

module OpenTok
  # A class for working with OpenTok 2.0 archives.
  class Archives

    # @private
    def initialize(client)
      @client = client
    end

    # Starts archiving an OpenTok 2.0 session.
    #
    # Clients must be actively connected to the OpenTok session for you to successfully start
    # recording an archive.
    #
    # You can only record one archive at a time for a given session. You can only record archives
    # of OpenTok server-enabled sessions; you cannot archive peer-to-peer sessions.
    #
    # @param [String] session_id The session ID of the OpenTok session to archive.
    # @param [Hash] options  A hash with the key 'name' or :name.
    # @option options [String] :name This is the name of the archive. You can use this name
    #   to identify the archive. It is a property of the Archive object, and it is a property
    #   of archive-related events in the OpenTok.js library.
    #
    # @return [Archive] The Archive object, which includes properties defining the archive,
    #   including the archive ID.
    #
    # @raise [OpenTokArchiveError] The archive could not be started. The request was invalid or
    #   the session has no connected clients.
    # @raise [OpenTokAuthenticationError] Authentication failed while starting an archive.
    #   Invalid API key.
    # @raise [OpenTokArchiveError] The archive could not be started. The session ID does not exist.
    # @raise [OpenTokArchiveError] The archive could not be started. The session could be
    #   peer-to-peer or the session is already being recorded.
    # @raise [OpenTokArchiveError] The archive could not be started.
    def create(session_id, options = {})
      raise ArgumentError, "session_id not provided" if session_id.to_s.empty?
      opts = Hash.new
      opts[:name] = options[:name].to_s || options["name"].to_s
      archive_json = @client.start_archive(session_id, opts)
      Archive.new self, archive_json
    end

    # Gets an Archive object for the given archive ID.
    #
    # @param [String] archive_id The archive ID.
    #
    # @return [Archive] The Archive object.
    # @raise [OpenTokArchiveError] The archive could not be retrieved. The archive ID is invalid.
    # @raise [OpenTokAuthenticationError] Authentication failed while retrieving the archive.
    #   Invalid API key.
    # @raise [OpenTokArchiveError] The archive could not be retrieved.
    def find(archive_id)
      raise ArgumentError, "archive_id not provided" if archive_id.to_s.empty?
      archive_json = @client.get_archive(archive_id.to_s)
      Archive.new self, archive_json
    end

    # Returns an ArchiveList, which is an array of archives that are completed and in-progress,
    # for your API key.
    #
    # @param [Hash] options  A hash with keys defining which range of archives to retrieve.
    # @option options [integer] :offset Optional. The index offset of the first archive. 0 is offset
    #   of the most recently started archive. 1 is the offset of the archive that started prior to
    #   the most recent archive. If you do not specify an offset, 0 is used.
    # @option options [integer] :count Optional. The number of archives to be returned. The maximum
    #   number of archives returned is 1000.
    #
    # @return [ArchiveList] An ArchiveList object, which is an array of Archive objects.
    def all(options = {})
      raise ArgumentError, "Limit is invalid" unless options[:count].nil? or (0..100).include? options[:count]
      archive_list_json = @client.list_archives(options[:offset], options[:count])
      ArchiveList.new self, archive_list_json
    end

    # Stops an OpenTok archive that is being recorded.
    #
    # Archives automatically stop recording after 90 minutes or when all clients have disconnected
    # from the session being archived.
    #
    # @param [String] archive_id The archive ID of the archive you want to stop recording.
    #
    # @return [Archive] The Archive object corresponding to the archive being stopped.
    #
    # @raise [OpenTokArchiveError] The archive could not be stopped. The request was invalid.
    # @raise [OpenTokAuthenticationError] Authentication failed while stopping an archive.
    # @raise [OpenTokArchiveError] The archive could not be stopped. The archive ID does not exist.
    # @raise [OpenTokArchiveError] The archive could not be stopped. The archive is not currently
    #   recording.
    # @raise [OpenTokArchiveError] The archive could not be started.
    def stop_by_id(archive_id)
      raise ArgumentError, "archive_id not provided" if archive_id.to_s.empty?
      archive_json = @client.stop_archive(archive_id)
      Archive.new self, archive_json
    end

    # Deletes an OpenTok archive.
    #
    # You can only delete an archive which has a status of "available", "uploaded", or "deleted".
    # Deleting an archive removes its record from the list of archives. For an "available" archive,
    # it also removes the archive file, making it unavailable for download. For a "deleted"
    # archive, the archive remains deleted.
    #
    # @param [String] archive_id The archive ID of the archive you want to delete.
    #
    # @raise [OpenTokAuthenticationError] Authentication failed or an invalid archive ID was given.
    # @raise [OpenTokArchiveError] The archive could not be deleted. The status must be
    #   'available', 'deleted', or 'uploaded'.
    # @raise [OpenTokArchiveError] The archive could not be deleted.
    def delete_by_id(archive_id)
      raise ArgumentError, "archive_id not provided" if archive_id.to_s.empty?
      response = @client.delete_archive(archive_id)
      (200..300).include? response.code
    end

  end
end
